#!/bin/bash

# prevent bc from adding \ at end of large hex values
export BC_LINE_LENGTH=9999
# test database, it is dropped before test run
export DB=mongodb://localhost:27017/CPStest

# $1 - error message
error()
{
  (>&2 echo $1)
  killAll
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
  programs/launcher/launcher -k 9
  kill -9 $WALLETD_PROC_ID
}

cleanup()
{
 rm -rf tn_data_00
 rm -rf test_wallet_0
 INFO="$(echo 'db.dropDatabase()' | mongo $DB)"
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
  INFO="$(echo 'db.Blocks.find().sort({"_id":-1}).limit(1).pretty()' | mongo $DB)"
  verifyErrorCode "mongo last block"
  HEAD_BLOCK_NUM="$(echo "$INFO" | awk '/block_num/ {print $3}')"
  # remove trailing coma
  HEAD_BLOCK_NUM=${HEAD_BLOCK_NUM%,}
}

waitForNextBlock()
{
  getHeadBlockNum
  NEXT_BLOCK_NUM=$((HEAD_BLOCK_NUM+2))
  while [ "$HEAD_BLOCK_NUM" -lt "$NEXT_BLOCK_NUM" ]; do
    sleep 0.25
    getHeadBlockNum
  done
}

getTransactionCount()
{
  INFO="$(echo 'print("count " + db.Transactions.count())' | mongo $DB)"
  TRANS_COUNT="$(echo "$INFO" | awk '/count/ {print $2}')"
}

waitForNextTransaction()
{
  getTransactionCount
  NEXT_TRANS_COUNT=$((TRANS_COUNT+1))
  echo "Waiting for next transaction $NEXT_TRANS_COUNT"
  while [ "$TRANS_COUNT" -lt "$NEXT_TRANS_COUNT" ]; do
    sleep 0.50
    getTransactionCount
  done
  echo "Done waiting for transaction $NEXT_TRANS_COUNT"
}

# cleanup from last run
cleanup

INITA_PRV_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
INITB_PRV_KEY="5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3"
LOG_FILE=cpsd_run_test.log

# cpsd
programs/launcher/launcher --cpsd "--plugin cpsio::db_plugin --mongodb-uri $DB"
verifyErrorCode "launcher"
sleep 60
count=`grep -c "generated block" tn_data_00/stderr.txt`
if [[ $count == 0 ]]; then
  error "FAILURE - no blocks produced"
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
ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 create account inita testera $PUB_KEY1 $PUB_KEY3)"
verifyErrorCode "cpsc create account"
waitForNextTransaction

# verify account created
ACCOUNT_INFO="$(echo 'db.Accounts.findOne({"name" : "testera"})' | mongo $DB)"
verifyErrorCode "mongo get account"
count=`echo $ACCOUNT_INFO | grep -c "staked_balance"`
if [ $count == 0 ]; then
  error "FAILURE - account creation failed: $ACCOUNT_INFO"
fi

# transfer
TRANSFER_INFO="$(programs/cpsc/cpsc --wallet-port 8899 transfer -f inita testera 975321 "test transfer")"
verifyErrorCode "cpsc transfer"
waitForNextTransaction

# verify transfer
ACCOUNT_INFO="$(echo 'db.Accounts.findOne({"name" : "testera"})' | mongo $DB)"
count=`echo $ACCOUNT_INFO | grep -c "97.5321"`
if [ $count == 0 ]; then
  error "FAILURE - transfer failed: $ACCOUNT_INFO"
fi

# create another new account via initb
ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 create account initb currency $PUB_KEY2 $PUB_KEY3)"
verifyErrorCode "cpsc create account"
waitForNextTransaction

## now transfer from testera to currency using keys from testera

# lock via lock_all
programs/cpsc/cpsc --wallet-port 8899 wallet lock_all
verifyErrorCode "cpsc wallet lock_all"

# unlock wallet
echo $PASSWORD | programs/cpsc/cpsc --wallet-port 8899 wallet unlock --name test
verifyErrorCode "cpsc wallet unlock"

# transfer
TRANSFER_INFO="$(programs/cpsc/cpsc --wallet-port 8899 transfer testera currency 975311 "test transfer a->b")"
verifyErrorCode "cpsc transfer"
waitForNextTransaction
getTransactionId "$TRANSFER_INFO"

# verify transfer
ACCOUNT_INFO="$(echo 'db.Accounts.findOne({"name" : "currency"})' | mongo $DB)"
verifyErrorCode "mongo get account currency"
count=`echo $ACCOUNT_INFO | grep -c "97.5311"`
if [ $count == 0 ]; then
  error "FAILURE - transfer failed: $ACCOUNT_INFO"
fi

# get accounts via public key
ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 get accounts $PUB_KEY3)"
verifyErrorCode "cpsc get accounts pub_key3"
count=`echo $ACCOUNT_INFO | grep -c "testera"`
if [ $count == 0 ]; then
  error "FAILURE - get accounts failed: $ACCOUNT_INFO"
fi
count=`echo $ACCOUNT_INFO | grep -c "currency"`
if [ $count == 0 ]; then
  error "FAILURE - get accounts failed: $ACCOUNT_INFO"
fi
ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 get accounts $PUB_KEY1)"
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
ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 get servants inita)"
verifyErrorCode "cpsc get servants inita"
count=`echo $ACCOUNT_INFO | grep -c "testera"`
if [ $count == 0 ]; then
  error "FAILURE - get servants failed: $ACCOUNT_INFO"
fi
count=`echo $ACCOUNT_INFO | grep -c "currency"`
if [ $count != 0 ]; then
  error "FAILURE - get servants failed: $ACCOUNT_INFO"
fi
ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 get servants testera)"
verifyErrorCode "cpsc get servants testera"
count=`echo $ACCOUNT_INFO | grep -c "testera"`
if [ $count != 0 ]; then
  error "FAILURE - get servants failed: $ACCOUNT_INFO"
fi

# get transaction
TRANS_INFO="$(echo 'db.Transactions.findOne({"transaction_id" : "'"$TRANS_ID"'"})' | mongo $DB)"
verifyErrorCode "mongo get transaction trans_id error: $TRANS_INFO"
count=`echo $TRANS_INFO | grep -c "block_id"`
if [ $count == 0 ]; then
  error "FAILURE - get transaction trans_id failed: $TRANS_INFO"
fi

# get transaction messages
TRANS_INFO="$(echo 'db.Messages.findOne({"transaction_id" : "'"$TRANS_ID"'"})' | mongo $DB)"
verifyErrorCode "mongo get messages trans_id of $TRANS_INFO"
count=`echo $TRANS_INFO | grep -c "transfer"`
if [ $count == 0 ]; then
  error "FAILURE - get messages trans_id failed: $TRANS_INFO"
fi
count=`echo $TRANS_INFO | grep -c "975311"`
if [ $count == 0 ]; then
  error "FAILURE - get messages trans_id failed: $TRANS_INFO"
fi

# get messages for account
TRANS_INFO="$(echo 'db.Messages.findOne({"authorization" : {$elemMatch:{"account" : "testera" }}})' | mongo $DB)"
verifyErrorCode "cpsc get messages testera"
count=`echo $TRANS_INFO | grep -c "$TRANS_ID"`
if [ $count == 0 ]; then
  error "FAILURE - get transactions testera failed: $TRANS_INFO"
fi

#
# Currency Contract Tests
#

# verify no contract in place
CODE_INFO="$(programs/cpsc/cpsc --wallet-port 8899 get code currency)"
verifyErrorCode "cpsc get code currency"
# convert to num
CODE_HASH="$(echo "$CODE_INFO" | awk '/code hash/ {print $3}')"
CODE_HASH="$(echo $CODE_HASH | awk '{print toupper($0)}')"
CODE_HASH="$(echo "ibase=16; $CODE_HASH" | bc)"
if [ $CODE_HASH != 0 ]; then
  error "FAILURE - get code currency failed: $CODE_INFO"
fi

# upload a contract
INFO="$(programs/cpsc/cpsc --wallet-port 8899 set contract currency contracts/currency/currency.wast contracts/currency/currency.abi)"
verifyErrorCode "cpsc set contract testera"
count=`echo $INFO | grep -c "processed"`
if [ $count == 0 ]; then
  error "FAILURE - set contract failed: $INFO"
fi
getTransactionId "$INFO"

waitForNextTransaction
# verify transaction exists
TRANS_INFO="$(echo 'db.Transactions.findOne({"transaction_id" : "'"$TRANS_ID"'"})' | mongo $DB)"
verifyErrorCode "mongod get transaction trans_id of $TRANS_INFO"

# verify abi is set
ACCOUNT_INFO="$(echo 'db.Accounts.findOne({"name" : "currency"})' | mongo $DB)"
verifyErrorCode "mongo get abi currency"
# convert to num
count=`echo $ACCOUNT_INFO | grep abi | grep -c "transfer"`
if [ $count == 0 ]; then
  error "FAILURE - set contract abi failed: $ACCOUNT_INFO"
fi

# verify currency contract has proper initial balance
INFO="$(programs/cpsc/cpsc --wallet-port 8899 get table currency currency account)"
verifyErrorCode "cpsc get table currency account"
count=`echo $INFO | grep -c "1000000000"`
if [ $count == 0 ]; then
  error "FAILURE - get table currency account failed: $INFO"
fi

# push message to currency contract
INFO="$(programs/cpsc/cpsc --wallet-port 8899 push message currency transfer '{"from":"currency","to":"inita","quantity":50}' --scope currency,inita --permission currency@active)"
verifyErrorCode "cpsc push message currency transfer"
getTransactionId "$INFO"

# verify transaction exists
waitForNextTransaction
TRANS_INFO="$(echo 'db.Transactions.findOne({"transaction_id" : "'"$TRANS_ID"'"})' | mongo $DB)"
verifyErrorCode "mongo get transaction trans_id of $TRANS_INFO"

# read current contract balance
ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 get table inita currency account)"
verifyErrorCode "cpsc get table currency account"
count=`echo $ACCOUNT_INFO | grep "balance" | grep -c "50"`
if [ $count == 0 ]; then
  error "FAILURE - get table inita account failed: $ACCOUNT_INFO"
fi

ACCOUNT_INFO="$(programs/cpsc/cpsc --wallet-port 8899 get table currency currency account)"
verifyErrorCode "cpsc get table currency account"
count=`echo $ACCOUNT_INFO | grep "balance" | grep -c "999999950"`
if [ $count == 0 ]; then
  error "FAILURE - get table currency account failed: $ACCOUNT_INFO"
fi

#
# Proxy
#
# not implemented

# should be able to get every block from beginning to end
getHeadBlockNum
CURRENT_BLOCK_NUM=$HEAD_BLOCK_NUM
NEXT_BLOCK_NUM=1
while [ "$NEXT_BLOCK_NUM" -le "$HEAD_BLOCK_NUM" ]; do
  INFO="$(echo 'db.Blocks.findOne({"block_num" : '"$NEXT_BLOCK_NUM"'})' | mongo $DB)"
  verifyErrorCode "mongo get block by num $NEXT_BLOCK_NUM"
  BLOCK_ID="$(echo "$INFO" | awk '/"block_id"/ {print $3}')"
  # remove trailing coma
  BLOCK_ID=${BLOCK_ID%,}
  INFO="$(echo 'db.Blocks.findOne({"block_id" : '"$BLOCK_ID"'})' | mongo $DB)"
  verifyErrorCode "mongo get block by id $BLOCK_ID"
  INFO="$(echo 'db.Transactions.find({"block_id" : '"$BLOCK_ID"'}).pretty()' | mongo $DB)"
  verifyErrorCode "mongo get transactions by block id $BLOCK_ID"
  count=`echo $INFO | grep -c "transaction_id"`
  if [ $count > 0 ]; then
    TRANS_IDS="$(echo "$INFO" | awk '/transaction_id/ {print $3}')"
    IFS=', ' read -r -a ARR <<< "$TRANS_IDS"
    for t in "${ARR[@]}"
    do
      INFO="$(echo 'db.Messages.findOne({"transaction_id" : '"$t"'})' | mongo $DB)"
      verifyErrorCode "mongo get messages by transaction id $t"
    done
  fi

  NEXT_BLOCK_NUM=$((NEXT_BLOCK_NUM+1))
done

ASSERT_ERRORS="$(grep Assert tn_data_00/stderr.txt)"
count=`grep -c Assert tn_data_00/stderr.txt`
if [ $count != 0 ]; then
  error "FAILURE - Assert in tn_data_00/stderr.txt"
fi

killAll
cleanup
echo SUCCESS!
