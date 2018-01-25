# This is a script/doc for introducing how to add a new orgnization to a running Fabric network

## Run configtlator tool
Start the configtxlator tool in the background, and verify that the tool has started correctly to receive incoming client requests:
```
$configtxlator start &
```

## Retrieve the current configuration of running Fabric network
Execute the following command in `cli` container to retrieve the current configuration block on the application channel named mychannel.
```
$peer channel fetch config config_block.pb -o orderer.example.com:7050 -c mychannel --tls --cafile \
     /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

$ls config_block.pb
```
## Decode the configuration into a human-readable version of JSON configuration
Decode the binary protobuf channel configuration block information into human-readable, textual JSON format using the configtxlator tool.
```
$curl -X POST --data-binary @config_block.pb http://127.0.0.1:7059/protolator/decode/common.Block > config_block.json
```

## Extract the config section
Extract the config section of data's payload data section from the decoded channel configuration block for application channel mychannel, and verify the correct and successful extraction.
```
$jq .data.data[0].payload.data.config config_block.json > config.json
```

## Create the new configuration by editing the extracted config section
Modify the channel configuration of application channel mychannel to add the new organization.

### Generate cryptos for new organization
```
$cryptogen generate --config=./crypto-config-org4.yaml
```
`crypto-config-org4.yaml` may look like the following:
```
PeerOrgs:
  - Name: Org4
    Domain: org4.example.com
    Template:
      Count: 1
    Users:
      Count: 1
```

### Update configuration file
Encode certs of Org4 using base64 and fill into the updated configuration file, e.g. updated_config.json for the new added org
```
admins -> crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp/admincerts/Admin@org4.example.com-cert.pem
root_certs -> crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp/cacerts/ca.org4.example.com-cert.pem
tls_root_certs -> crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp/tlscacerts/tlsca.org4.example.com-cert.pem
```
CMD to run:
```
$cat *.pem | base64 | sed ":a;N;s/\n//g;ta"
```

## Generate pb file for updating configuration
### Encode the original channel configuration of the application channel mychannel into protobuf using configtxlator
```
$curl -X POST --data-binary @config.json http://127.0.0.1:7059/protolator/encode/common.Config > config.pb
```

### Encode the modified channel configuration of the application channel mychannel into protobuf
```
$curl -X POST --data-binary @updated_config.json http://127.0.0.1:7059/protolator/encode/common.Config > updated_config.pb
```

### Send them to configtxlator to compute the config update delta
```
$curl -X POST -F original=@config.pb -F updated=@updated_config.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs \
     -F channel=mychannel > config_update.pb
```

### Decode the configuration update into JSON format, and verify the decoding operation
```
$curl -X POST --data-binary @config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > config_update.json
```

### Create an envelope for the configuration update message in JSON format
```
$echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' > config_update_as_envelope.json
```

## Create the new config transaction
### Encode a configuration update message into a protobuf format
```
$curl -X POST --data-binary @config_update_as_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > config_update_as_envelope.pb
```

## Update the channel by submitting the new signed config transaction
***Note: The following operations can be performed in a peer container or cli container.***

Set the environment to be Org1MSP with an admin privileged user in preparation for signing the configuration update transaction.
```
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org1MSP
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
```

Execute the following command to sign the configuration update transaction.
```
$peer channel signconfigtx -f config_update_as_envelope.pb -o orderer.example.com:7050 --tls --cafile ./crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

Repeat the last step for org2 and any other orgs already exit to collect their signatures on this channel update transaction
...

Set the environment to be the last exiting org msp, e.g. Org3MSP with an admin privileged user in preparation for signing and submitting the update transaction.
```
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org3MSP
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
```

Execute the following command to submit the configuration update transaction. The update command automatically adds the user's signature to the configuration update before submitting it to the orderer (so signconfigtx is not needed for org3)
```
$peer channel update -f config_update_as_envelope.pb -o orderer.example.com:7050 -c mychannel --tls --cafile \
     /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```

## Verify the update tx result
Fetch the updated current configuration.
```
$peer channel fetch config config_block_Org4MSP.pb -o orderer.example.com:7050 -c mychannel --tls --cafile \
     /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
```
Decode the successfully updated current channel configuration, and verify correct operation.
```
$curl -X POST --data-binary @config_block_Org4MSP.pb http://127.0.0.1:7059/protolator/decode/common.Block > config_block_Org4MSP.json
```

## Boot up peer node for new org
Update the configtx.yaml to add new org, e.g. Org4, and then generate channel requreid artifacts which is `Org4MSPanchors.tx` here.
```
export ORG_MSP_NAME=Org4MSP
export CHANNEL_NAME=mychannel
configtxgen -profile OrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/${ORG_MSP_NAME}anchors.tx -channelID $CHANNEL_NAME -asOrg ${ORG_MSP_NAME}
```

Update docker-compose template to add peer0.org7 and also ca7 and run the following command to update the deployment.
```
$docker-compose -f *.yaml up
```
or
```
$fabric.sh -m up
```

## Let new peer join the channel and update anchor peer
Enter cli container to run peer CMD and perform the following operations:
- Let peer0.org7 join mychannel
- Install chaincode in peer0.org7
Note: Anchor peer of Org7 has been updated during the update of channel configuration. So no need to do it again here.

Now you can query or invoke chaincode by talking to this new peer0.org7 using Org7 Admin credential.
