#!/bin/bash
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}*     1 Click Garap Rainbow Protocol by           *${NC}"
echo -e "${CYAN}${BOLD}*               Airdrop Sultan                    *${NC}"
echo ""
echo -e "${YELLOW}${BOLD}This entire code is created by Brian (x.com/brianeedsleep)${NC}"
echo -e "${YELLOW}${BOLD}Make sure you have joined Airdrop Sultan at t.me/airdropsultanindonesia${NC}"
echo ""
read -p "Enter Bitcoin Core RPC Username: " RPC_USER
read -sp "Enter Bitcoin Core RPC Password: " RPC_PASSWORD
echo
read -p "Enter Bitcoin Core RPC Allow IP (e.g., 127.0.0.1): " RPC_ALLOW_IP
read -p "Enter Bitcoin Core RPC Port (e.g., 5000): " RPC_PORT
read -p "Enter Start Height (e.g., 42000): " START_HEIGHT
read -p "Enter Wallet Name: " WALLET_NAME

BITCOIN_CORE_REPO="https://github.com/mocacinno/btc_testnet4"
INDEXER_URL="https://github.com/rainbowprotocol-xyz/rbo_indexer_testnet/releases/download/v0.0.1-alpha/rbo_worker"
BITCOIN_CORE_DATA_DIR="/root/project/run_btc_testnet4/data"
DOCKER_COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"

apt-get update
apt-get install -y docker.io docker-compose wget

mkdir -p $BITCOIN_CORE_DATA_DIR

git clone $BITCOIN_CORE_REPO
cd btc_testnet4

git switch bci_node

rm -f $DOCKER_COMPOSE_FILE

cat <<EOF > $DOCKER_COMPOSE_FILE
version: '3'
services:
  bitcoind:
    image: mocacinno/btc_testnet4:bci_node
    privileged: true
    container_name: bitcoind
    volumes:
      - /root/project/run_btc_testnet4/data:/root/.bitcoin/
    command: ["bitcoind", "-testnet4", "-server", "-rpcuser=$RPC_USER", "-rpcpassword=$RPC_PASSWORD", "-rpcallowip=$RPC_ALLOW_IP", "-rpcport=$RPC_PORT"]
    ports:
      - "8333:8333"
      - "48332:48332"
      - "$RPC_PORT:$RPC_PORT"
EOF

cat $DOCKER_COMPOSE_FILE

docker-compose up -d

sleep 30

docker exec -it bitcoind /bin/bash -c "bitcoin-cli -testnet4 -rpcuser=$RPC_USER -rpcpassword=$RPC_PASSWORD -rpcport=$RPC_PORT createwallet $WALLET_NAME"
docker exec -it bitcoind /bin/bash -c "exit"

wget $INDEXER_URL
chmod +x rbo_worker

echo "INDEXER_LOGGER_FILE=./logs/indexer" > $ENV_FILE

./rbo_worker worker --rpc http://127.0.0.1:5000 --password {bitcoin_core_password} --username {bitcoin_core_username} --start_height $START_HEIGHT

echo "Setup completed. Make sure to check the JSON file and save your private key."

echo "For support, you don’t need to donate. Just follow me on x.com/brianeedsleep and join t.me/airdropsultanindonesia"
