#!/bin/bash

# prevent bc from adding \ at end of large hex values
export BC_LINE_LENGTH=9999

TEST_OUTPUT="test_output_0.txt"

if [ $# -lt 2 ]; then
  echo "usage: cpsd_run_test.sh --host=host_name --port=port --output=test_output_0.txt"
  echo "  If --host==localhost then this script also launches an cpsd for the test."
  echo "  Example: cpsd_run_test_sh --host=localhost --port=8888 --output=test_output_0.txt"
  exit 1
fi

for i in "$@"
do
case $i in
	-o*|--output=*)
	TEST_OUTPUT="${i#*=}"
	shift
	;;
        -h*|--host=*)
	SERVER="${i#*=}"
	shift
	;;
        -p*|--port=*)
	PORT="${i#*=}"
	shift
	;;
        *)
	;;
esac
done


# $1 - error message
error()
{
  (>&2 echo $1)
  killAll
  echo =================================================================
  echo Contents of tn_data_00/config.ini:
  cat tn_data_00/config.ini
  echo =================================================================
  echo Contents of tn_data_00/stderr.txt:
  cat tn_data_00/stderr.txt
  echo =================================================================
  echo Contents of test_walletd_output.log:
  cat test_walletd_output.log
  echo =================================================================
  echo == Errors see above ==
  exit 1
}

verifyErrorCode()
{
  rc=$?
  if [[ $rc != 0 ]]; then
    error "FAILURE - $1 returned error code $rc"
  fi
}

killAll()
{
  if [ "$SERVER" == "localhost" ]; then
    programs/launcher/launcher -k 9
  fi
  kill -9 $WALLETD_PROC_ID
}

cleanup()
{
  if [ "$SERVER" == "localhost" ]; then
    rm -rf tn_data_00
  fi
  rm -rf test_wallet_0
}

# $1 - string that contains "transaction_id": "<trans id>", in it
# result <trans id> stored in TRANS_ID
getTransactionId()
{
  TRANS_ID="$(echo "$1" | awk '/transaction_id/ {print $2}')"
  # remove leading/trailing quotes
  TRANS_ID=${TRANS_ID#\"}
  TRANS_ID=${TRANS_ID%\",}
}

# result stored in HEAD_BLOCK_NUM
getHeadBlockNum()
{
  INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT get info)"
  verifyErrorCode "cpsc get info"
  HEAD_BLOCK_NUM="$(echo "$INFO" | awk '/head_block_num/ {print $2}')"
  # remove trailing coma
  HEAD_BLOCK_NUM=${HEAD_BLOCK_NUM%,}
}

waitForNextBlock()
{
  getHeadBlockNum
  NEXT_BLOCK_NUM=$((HEAD_BLOCK_NUM+1))
  while [ "$HEAD_BLOCK_NUM" -lt "$NEXT_BLOCK_NUM" ]; do
    sleep 0.25
    getHeadBlockNum
  done
}

# cleanup from last run
cleanup

echo "BEGIN" > $TEST_OUTPUT
echo "TEST_OUTPUT: ${TEST_OUTPUT}"
echo "SERVER: ${SERVER}"
echo "PORT: ${PORT}"

INITA_PRV_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
INITB_PRV_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
LOG_FILE=cpsd_run_test.log

# cpsd
if [ "$SERVER" == "localhost" ]; then
  programs/launcher/launcher
  verifyErrorCode "launcher"
  sleep 7
  count=`grep -c "generated block" tn_data_00/stderr.txt`
  if [[ $count == 0 ]]; then
    error "FAILURE - no blocks produced"
  fi
fi

# save starting block number
getHeadBlockNum
START_BLOCK_NUM=$HEAD_BLOCK_NUM

# create 3 keys
KEYS="$(programs/cpsc/cpsc create key)"
verifyErrorCode "cpsc create key"
PRV_KEY1="$(echo "$KEYS" | awk '/Private/ {print $3}')"
PUB_KEY1="$(echo "$KEYS" | awk '/Public/ {print $3}')"
KEYS="$(programs/cpsc/cpsc create key)"
verifyErrorCode "cpsc create key"
PRV_KEY2="$(echo "$KEYS" | awk '/Private/ {print $3}')"
PUB_KEY2="$(echo "$KEYS" | awk '/Public/ {print $3}')"
KEYS="$(programs/cpsc/cpsc create key)"
verifyErrorCode "cpsc create key"
PRV_KEY3="$(echo "$KEYS" | awk '/Private/ {print $3}')"
PUB_KEY3="$(echo "$KEYS" | awk '/Public/ {print $3}')"
if [ -z "$PRV_KEY1" ] || [ -z "$PRV_KEY2" ] || [ -z "$PRV_KEY3" ] || [ -z "$PUB_KEY1" ] || [ -z "$PUB_KEY2" ] || [ -z "$PUB_KEY3" ]; then
  error "FAILURE - create keys"
fi

#
# Wallet Tests
#

# walletd
programs/cps-walletd/cps-walletd --data-dir test_wallet_0 --http-server-address=127.0.0.1:8899 > test_walletd_output.log 2>&1 &
verifyErrorCode "cps-walletd"
WALLETD_PROC_ID=$!
sleep 3

# import into a wallet
PASSWORD="$(programs/cpsc/cpsc --wallet-port 8899 wallet create --name test)"
verifyErrorCode "cpsc wallet create"
# strip out password from output
PASSWORD="$(echo "$PASSWORD" | awk '/PW/ {print $1}')"
# remove leading/trailing quotes
PASSWORD=${PASSWORD#\"}
PASSWORD=${PASSWORD%\"}
programs/cpsc/cpsc --wallet-port 8899 wallet import --name test $PRV_KEY1
verifyErrorCode "cpsc wallet import"
programs/cpsc/cpsc --wallet-port 8899 wallet import --name test $PRV_KEY2
verifyErrorCode "cpsc wallet import"
programs/cpsc/cpsc --wallet-port 8899 wallet import --name test $PRV_KEY3
verifyErrorCode "cpsc wallet import"

# create wallet for inita
PASSWORD_INITA="$(programs/cpsc/cpsc --wallet-port 8899 wallet create --name inita)"
verifyErrorCode "cpsc wallet create"
# strip out password from output
PASSWORD_INITA="$(echo "$PASSWORD_INITA" | awk '/PW/ {print $1}')"
# remove leading/trailing quotes
PASSWORD_INITA=${PASSWORD_INITA#\"}
PASSWORD_INITA=${PASSWORD_INITA%\"}
programs/cpsc/cpsc --wallet-port 8899 wallet import --name inita $INITA_PRV_KEY
verifyErrorCode "cpsc wallet import"

# lock wallet
programs/cpsc/cpsc --wallet-port 8899 wallet lock --name test
verifyErrorCode "cpsc wallet lock"

# unlock wallet
echo $PASSWORD | programs/cpsc/cpsc --wallet-port 8899 wallet unlock --name test
verifyErrorCode "cpsc wallet unlock"

# lock via lock_all
programs/cpsc/cpsc --wallet-port 8899 wallet lock_all
verifyErrorCode "cpsc wallet lock_all"

# unlock wallet again
echo $PASSWORD | programs/cpsc/cpsc --wallet-port 8899 wallet unlock --name test
verifyErrorCode "cpsc wallet unlock"

# wallet list
OUTPUT=$(programs/cpsc/cpsc --wallet-port 8899 wallet list)
verifyErrorCode "cpsc wallet list"
count=`echo $OUTPUT | grep "test" | grep -c "\*"`
if [[ $count == 0 ]]; then
  error "FAILURE - wallet list did not include \*"
fi

# wallet keys
OUTPUT=$(programs/cpsc/cpsc --wallet-port 8899 wallet keys)
verifyErrorCode "cpsc wallet keys"
count=`echo $OUTPUT | grep -c "$PRV_KEY1"`
if [[ $count == 0 ]]; then
  error "FAILURE - wallet keys did not include $PRV_KEY1"
fi
count=`echo $OUTPUT | grep -c "$PRV_KEY2"`
if [[ $count == 0 ]]; then
  error "FAILURE - wallet keys did not include $PRV_KEY2"
fi

# lock via lock_all
programs/cpsc/cpsc --wallet-port 8899 wallet lock_all
verifyErrorCode "cpsc wallet lock_all"

# unlock wallet inita
echo $PASSWORD_INITA | programs/cpsc/cpsc --wallet-port 8899 wallet unlock --name inita
verifyErrorCode "cpsc wallet unlock inita"
OUTPUT=$(programs/cpsc/cpsc --wallet-port 8899 wallet keys)
count=`echo $OUTPUT | grep -c "$INITA_PRV_KEY"`
if [[ $count == 0 ]]; then
  error "FAILURE - wallet keys did not include $INITA_PRV_KEY"
fi

#
# Account and Transfer Tests
#

# create new account
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 create account inita testera $PUB_KEY1 $PUB_KEY3)"
verifyErrorCode "cpsc create account"
waitForNextBlock

# verify account created
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get account testera)"
verifyErrorCode "cpsc get account"
count=`echo $ACCOUNT_INFO | grep -c "staked_balance"`
if [ $count == 0 ]; then
  error "FAILURE - account creation failed: $ACCOUNT_INFO"
fi

# transfer
TRANSFER_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 transfer inita testera 975321 "test transfer")  -x 3000"
verifyErrorCode "cpsc transfer"

# verify transfer
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get account testera)"
count=`echo $ACCOUNT_INFO | grep -c "97.5321"`
if [ $count == 0 ]; then
  error "FAILURE - transfer failed: $ACCOUNT_INFO"
fi

# force transfer
TRANSFER_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 transfer inita testera 100 "test transfer" -f)  -x 3000"
verifyErrorCode "cpsc force transfer"

# verify force transfer
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get account testera)"
count=`echo $ACCOUNT_INFO | grep -c "97.5421"`
if [ $count == 0 ]; then
  error "FAILURE - transfer failed: $ACCOUNT_INFO"
fi


# create another new account via initb
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 create account initb currency $PUB_KEY2 $PUB_KEY3)"
verifyErrorCode "cpsc create account currency"

# create another new account via inita
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 create account inita exchange $PUB_KEY2 $PUB_KEY3)"
verifyErrorCode "cpsc create account exchange"
waitForNextBlock


## now transfer from testera to currency using keys from testera

# lock via lock_all
programs/cpsc/cpsc --wallet-port 8899 wallet lock_all
verifyErrorCode "cpsc wallet lock_all"

# unlock wallet
echo $PASSWORD | programs/cpsc/cpsc --wallet-port 8899 wallet unlock --name test
verifyErrorCode "cpsc wallet unlock"

# transfer
TRANSFER_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 transfer testera currency 975311 "test transfer a->b")  -x 3000"
verifyErrorCode "cpsc transfer"
waitForNextBlock
getTransactionId "$TRANSFER_INFO"

# verify transfer
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get account currency)"
verifyErrorCode "cpsc get account currency"
count=`echo $ACCOUNT_INFO | grep -c "97.5311"`
if [ $count == 0 ]; then
  error "FAILURE - transfer failed: $ACCOUNT_INFO"
fi

# get accounts via public key
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get accounts $PUB_KEY3)"
verifyErrorCode "cpsc get accounts pub_key3"
count=`echo $ACCOUNT_INFO | grep -c "testera"`
if [ $count == 0 ]; then
  error "FAILURE - get accounts failed: $ACCOUNT_INFO"
fi
count=`echo $ACCOUNT_INFO | grep -c "currency"`
if [ $count == 0 ]; then
  error "FAILURE - get accounts failed: $ACCOUNT_INFO"
fi
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get accounts $PUB_KEY1)"
verifyErrorCode "cpsc get accounts pub_key1"
count=`echo $ACCOUNT_INFO | grep -c "testera"`
if [ $count == 0 ]; then
  error "FAILURE - get accounts failed: $ACCOUNT_INFO"
fi
count=`echo $ACCOUNT_INFO | grep -c "currency"`
if [ $count != 0 ]; then
  error "FAILURE - get accounts failed: $ACCOUNT_INFO"
fi

# get servant accounts
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get servants inita)"
verifyErrorCode "cpsc get servants inita"
count=`echo $ACCOUNT_INFO | grep -c "testera"`
if [ $count == 0 ]; then
  error "FAILURE - get servants failed: $ACCOUNT_INFO"
fi
count=`echo $ACCOUNT_INFO | grep -c "currency"`
if [ $count != 0 ]; then
  error "FAILURE - get servants failed: $ACCOUNT_INFO"
fi
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get servants testera)"
verifyErrorCode "cpsc get servants testera"
count=`echo $ACCOUNT_INFO | grep -c "testera"`
if [ $count != 0 ]; then
  error "FAILURE - get servants failed: $ACCOUNT_INFO"
fi

# get transaction
TRANS_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get transaction $TRANS_ID)"
verifyErrorCode "cpsc get transaction trans_id of $TRANS_INFO"
count=`echo $TRANS_INFO | grep -c "transfer"`
if [ $count == 0 ]; then
  error "FAILURE - get transaction trans_id failed: $TRANS_INFO"
fi
count=`echo $TRANS_INFO | grep -c "975311"`
if [ $count == 0 ]; then
  error "FAILURE - get transaction trans_id failed: $TRANS_INFO"
fi

# get transactions
TRANS_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT  --wallet-port 8899 get transactions testera)"
verifyErrorCode "cpsc get transactions testera"
count=`echo $TRANS_INFO | grep -c "$TRANS_ID"`
if [ $count == 0 ]; then
  error "FAILURE - get transactions testera failed: $TRANS_INFO"
fi

#
# Currency Contract Tests
#

# verify no contract in place
CODE_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get code currency)"
verifyErrorCode "cpsc get code currency"
# convert to num
CODE_HASH="$(echo "$CODE_INFO" | awk '/code hash/ {print $3}')"
CODE_HASH="$(echo $CODE_HASH | awk '{print toupper($0)}')"
CODE_HASH="$(echo "ibase=16; $CODE_HASH" | bc)"
if [ $CODE_HASH != 0 ]; then
  error "FAILURE - get code currency failed: $CODE_INFO"
fi

# upload a contract
INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 set contract currency contracts/currency/currency.wast contracts/currency/currency.abi)"
verifyErrorCode "cpsc set contract currency"
count=`echo $INFO | grep -c "processed"`
if [ $count == 0 ]; then
  error "FAILURE - set contract failed: $INFO"
fi
getTransactionId "$INFO"

waitForNextBlock
# verify transaction exists
TRANS_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get transaction $TRANS_ID)"
verifyErrorCode "cpsc get transaction trans_id of $TRANS_INFO"

# verify code is set
CODE_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get code currency)"
verifyErrorCode "cpsc get code currency"
# convert to num
CODE_HASH="$(echo "$CODE_INFO" | awk '/code hash/ {print $3}')"
CODE_HASH="$(echo $CODE_HASH | awk '{print toupper($0)}')"
CODE_HASH="$(echo "ibase=16; $CODE_HASH" | bc)"
if [ $CODE_HASH == 0 ]; then
  error "FAILURE - get code currency failed: $CODE_INFO"
fi

# verify currency contract has proper initial balance
INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get table currency currency account)"
verifyErrorCode "cpsc get table currency account"
count=`echo $INFO | grep -c "1000000000"`
if [ $count == 0 ]; then
  error "FAILURE - get table currency account failed: $INFO"
fi
count=`echo $INFO | grep -c "account"`
if [ $count == 0 ]; then
  error "FAILURE - get table currency account failed: $INFO"
fi

# push message to currency contract

INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 push message currency transfer '{"from":"currency","to":"inita","quantity":50}' --scope currency,inita --permission currency@active)"
verifyErrorCode "cpsc push message currency transfer"
getTransactionId "$INFO"

# verify transaction exists
waitForNextBlock
TRANS_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get transaction $TRANS_ID)"
verifyErrorCode "cpsc get transaction trans_id of $TRANS_INFO"

# read current contract balance
ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get table inita currency account)"
verifyErrorCode "cpsc get table currency account"
count=`echo $ACCOUNT_INFO | grep "balance" | grep -c "50"`
if [ $count == 0 ]; then
  error "FAILURE - get table inita account failed: $ACCOUNT_INFO"
fi

ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get table currency currency account)"
verifyErrorCode "cpsc get table currency account"
count=`echo $ACCOUNT_INFO | grep "balance" | grep -c "999999950"`
if [ $count == 0 ]; then
  error "FAILURE - get table currency account failed: $ACCOUNT_INFO"
fi

#
# Exchange Contract Tests
#

# upload exchange contract
INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 set contract exchange contracts/exchange/exchange.wast contracts/exchange/exchange.abi)"
verifyErrorCode "cpsc set contract exchange"
count=`echo $INFO | grep -c "processed"`
if [ $count == 0 ]; then
  error "FAILURE - set contract exchange failed: $INFO"
fi
getTransactionId "$INFO"

#
# Setting simpledb contract without simpledb account was causing core dump in cpsc.
# Verify cpsc generates an error, but does not core dump.
#

INFO="$( { programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 set contract simpledb contracts/simpledb/simpledb.wast contracts/simpledb/simpledb.abi ; } 2>&1 )"
rc=$?
if [ $rc -eq 0 ] || [ $rc -eq 139 ]; then # 139 SIGSEGV
  error "FAILURE - $1 returned error code $rc, should have failed to execute."
fi

#
# Producer
#

INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 create producer testera $PUB_KEY1)"
verifyErrorCode "cpsc create producer"
getTransactionId "$INFO"

# set permission
INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 set action permission testera currency transfer active)"
verifyErrorCode "cpsc set action permission set"
waitForNextBlock

# remove permission
INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 set action permission testera currency transfer null)"
verifyErrorCode "cpsc set action permission delete"

# lock via lock_all
programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 wallet lock_all
verifyErrorCode "cpsc wallet lock_all"

# unlock wallet inita
echo $PASSWORD_INITA | programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 wallet unlock --name inita
verifyErrorCode "cpsc wallet unlock inita"

# TODO: Approving producers currently not supported
# approve producer
# INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 set producer inita testera approve)"
# verifyErrorCode "cpsc approve producer"

ACCOUNT_INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 get account inita)"
verifyErrorCode "cpsc get account"

# TODO: Unapproving producers currently not supported
# unapprove producer
# INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT --wallet-port 8899 set producer inita testera unapprove)"
# verifyErrorCode "cpsc unapprove producer"

#
# Proxy
#
# not implemented

# should be able to get every block from beginning to end
getHeadBlockNum
CURRENT_BLOCK_NUM=$HEAD_BLOCK_NUM
NEXT_BLOCK_NUM=1
while [ "$NEXT_BLOCK_NUM" -le "$HEAD_BLOCK_NUM" ]; do
  INFO="$(programs/cpsc/cpsc --host $SERVER --port $PORT get block $NEXT_BLOCK_NUM)"
  verifyErrorCode "cpsc get block"
  NEXT_BLOCK_NUM=$((NEXT_BLOCK_NUM+1))
done

if [ "$SERVER" == "localhost" ]; then
  ASSERT_ERRORS="$(grep Assert tn_data_00/stderr.txt)"
  count=`grep -c Assert tn_data_00/stderr.txt`
  if [ "$count" != "0" ]; then
    error "FAILURE - Assert in tn_data_00/stderr.txt"
  fi
fi

killAll
cleanup
echo "END" >> $TEST_OUTPUT
echo SUCCESS!
