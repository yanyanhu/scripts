# Start Indy container for test. The command line tool will be run inside this docker to act as a client
export IPS=172.17.0.1,172.17.0.1,172.17.0.1,172.17.0.1
docker run --rm --name Indy -it indy-base /bin/bash -c "create_dirs.sh; generate_indy_pool_transactions --nodes 4 --clients 5 --ips $IPS; /root/scripts/indy-cli"

# To Read transaction history from ledger, run the following cmd in Node
read_ledger --type domain
