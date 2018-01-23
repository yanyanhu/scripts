# Generate cryptos for new organization
cryptogen generate --config=./crypto-config-org7.yaml

# Encode certs using base64 and fill into the updated configuration file, e.g. updated_config.json for the new added org
admins -> crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp/admincerts/Admin@org7.example.com-cert.pem
root_certs -> crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp/cacerts/ca.org7.example.com-cert.pem
tls_root_certs -> crypto-config/peerOrganizations/org7.example.com/users/Admin@org7.example.com/msp/tlscacerts/tlsca.org7.example.com-cert.pem

cat *.pem | base64 | sed ":a;N;s/\n//g;ta"

# Encode the original channel configuration of the application channel mychannel into protobuf using configtxlator
curl -X POST --data-binary @config.json http://127.0.0.1:7059/protolator/encode/common.Config > config.pb

# Encode the modified channel configuration of the application channel mychannel into protobuf using  configtxlator
curl -X POST --data-binary @updated_config.json http://127.0.0.1:7059/protolator/encode/common.Config > updated_config.pb

# Send them to configtxlator to compute the config update delta
curl -X POST -F original=@config.pb -F updated=@updated_config.pb http://127.0.0.1:7059/configtxlator/compute/update-from-configs \
    -F channel=mychannel > config_update.pb

# Decode the configuration update into JSON format, and verify the decoding operation
curl -X POST --data-binary @config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > config_update.json

# Create an envelope for the configuration update message in JSON format, and verify the successful envelope creation step
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' > config_update_as_envelope.json

# Create the new config transaction
# Encode a configuration update message into a protobuf format, and verify that the encoding operation is successful
curl -X POST --data-binary @config_update_as_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > config_update_as_envelope.pb

# Update the channel by submitting the new signed config transaction
# The following operations can be performed in a peer container or cli container.

# Set the environment to be Org1MSP with an admin privileged user in preparation for signing the configuration update transaction
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org1MSP
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

#Execute the following command to sign the configuration update transaction. 
peer channel signconfigtx -f config_update_as_envelope.pb -o orderer.example.com:7050 --tls --cafile ./crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Repeat the same opertion for org2, org3, org4, org5 to collect their signature on this channel update transaction
...

# Set the environment to be the latest org msp, e.g. Org6MSP with an admin privileged user in preparation for signing and submitting the update transaction
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/ca.crt
CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/server.key
CORE_PEER_LOCALMSPID=Org6MSP
CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/peers/peer0.org6.example.com/tls/server.crt
CORE_PEER_TLS_ENABLED=true
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org6.example.com/users/Admin@org6.example.com/msp

# Execute the following command to submit the configuration update transaction.
# The update command automatically adds the user's signature to the configuration
# update before submitting it to the orderer (so signconfigtx is not needed for org6)
peer channel update -f config_update_as_envelope.pb -o orderer.example.com:7050 -c mychannel --tls --cafile \
    /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Fetch the updated current configuration
peer channel fetch config config_block_Org7MSP.pb -o orderer.example.com:7050 -c mychannel --tls --cafile \
    /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

# Decode the successfully updated current channel configuration, and verify correct operation
curl -X POST --data-binary @config_block_Org7MSP.pb http://127.0.0.1:7059/protolator/decode/common.Block > config_block_Org7MSP.json
