# Most common used command for geth
## Connect to main network
geth --datadir /home/huyanyan/ethereum/datadir/ --syncmode "fast" --cache 1024 --rpc --rpcaddr "127.0.0.1" --rpcport "8545"
geth attach /home/huyanyan/ethereum/datadir/geth.ipc

## Connect to testnet ropsten
geth --testnet --fast --datadir /home/huyanyan/ethereum/ropsten/datadir/  --cache 1024 --rpc --rpcaddr "127.0.0.1" --rpcport "8545" "enode://20c9ad97c081d63397d7b685a412227a40e23c8bdc6688c6f37e97cfbc22d2b4d1db1510d8f61e6a8866ad7f0e17c02b14182d37ea7c3c8b9c2683aeb6b733a1@52.169.14.227:30303,enode://6ce05930c72abc632c58e2e4324f7c7ea478cec0ed4fa2528982cf34483094e9cbc9216e7aa349691242576d552a2a56aaeae426c5303ded677ce455ba1acd9d@13.84.180.240:30303"

## Import private key of metamask wallet to geth
1. Go to the account in Metamask and Export the account you want. This will give you the private key.
2. Paste the private key to local file, e.g. priv-key
3. Run the following cmd to import priv-key: `geth --testnet account import --datadir /home/huyanyan/ethereum/ropsten/datadir/ priv-key`
4. You should see the new account immediately in geth console by typing web3.eth.accounts
***Note***: do remember to remove the priv-key file after import it to the geth wallet!

## Extra step to configure coinbase account
In case your primary account or "coinbase" did not change, we can change the timestamp in the filename of the accounts. So:
5. Navigate to ~/Library/Ethereum/keystore or ~/Library/Ethereum/testnet/keystore and change the dates so that the account you desire to be 'coinbase' is earliest.
6. Change the contents of priv-key, save it, then delete it.
You can restart geth and type web3.eth.coinbase to verify everything worked!

Ref: https://ethereum.stackexchange.com/questions/3447/how-can-i-get-my-accounts-into-metamask-or-vise-versa

## Unlock account
geth>web3.personal.unlockAccount(web3.personal.listAccounts[0],"<password>", 15000)
