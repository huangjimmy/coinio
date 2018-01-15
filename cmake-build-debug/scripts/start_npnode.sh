cd testnet_np
rm -rf blocks blockchain std*
cd ..
../programs/cpsd/cpsd --data-dir testnet_np --replay-blockchain > testnet_np/stdout.txt 2> testnet_np/stderr.txt &
echo Launched cpsd.
echo See testnet_np/stderr.txt for cpsd output.
echo Synching requires at least 8 minutes, depending on network conditions.
