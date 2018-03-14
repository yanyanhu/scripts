## Basic operations of truffle

### Init project
>truffle init

### Compile Smart Contract
>truffle compile

### Deploy Smart Contract
>truffle migrate --network localnode

### Connect to local node
>truffle console --network localnode

### Redeploy Smart Contract
>truffle migrate --reset --network localnode

### Sample truffle-config.js
```
module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        localnode: {
            network_id: "*",
            host: "localhost",
            port: 8545,
            from: "0xed3bd7dc2198afea500e4fc1c6041de871ad6baf",
            gas: 4700000,
            gasPrice: 100000000000,
        },
        ganache: {
            network_id: "3",
            host: "localhost",
            port: 8546,
            from: "0x546ecf360fcf266d44c725cd4b7ea4c7172151ce",
            gas: 8000000,
            gasPrice: 100000000000,
        }
    }
};
```
