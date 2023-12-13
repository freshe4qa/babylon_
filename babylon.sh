#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export BABYLON_CHAIN_ID=bbn-test-2" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

# install go
if ! [ -x "$(command -v go)" ]; then
ver="1.20.3" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile
fi

# download binary
cd $HOME
rm -rf babylon
git clone https://github.com/babylonchain/babylon.git
cd babylon
git checkout v0.7.2

# config
babylond config chain-id $BABYLON_CHAIN_ID
babylond config keyring-backend test

# init
babylond init $NODENAME --chain-id $BABYLON_CHAIN_ID

# download genesis and addrbook
curl -Ls https://snapshots.kjnodes.com/babylon-testnet/genesis.json > $HOME/.babylond/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/babylon-testnet/addrbook.json > $HOME/.babylond/config/addrbook.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00001ubbn\"/" $HOME/.babylond/config/app.toml

# set peers and seeds
SEEDS="3f472746f46493309650e5a033076689996c8881@babylon-testnet.rpc.kjnodes.com:16459"
PEERS="6f55a3138d18e8c0eaa66e347794428db698bf2a@148.251.176.236:2000,889af26cbc60b4c1aa768ce7c2c564c2cca14042@78.46.74.23:29656,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:16456,9a136cc5129e7067f632a5bcbdfddbf19464ae53@173.249.49.114:31156,3287ddbe454cfb5a162799b468c1405b7370c541@95.217.199.12:26601,7e2c922b8281f7db344c4005dcbf395ad123f01c@194.163.179.176:26656,c8a4b164ff44113d09a14dc53a75d534716bb150@94.130.132.227:2170,c23f881816d1ce92e78512f1f61b1e6933aaafa3@164.132.206.199:16456,1e982801965646df71f023232ac4234767e2fd7b@35.200.2.10:26656,8da45f9ff83b4f8dd45bbcb4f850999637fbfe3b@18.118.32.0:26656,e52adc8c65147f2388ae85e467dcac26ba06e347@109.123.232.223:27756,24a9243035d790fa542a3b30892ac965418f87d4@91.230.110.92:16456,7dc9186904b7eec46e24906e0560061b716d723e@31.220.79.106:31156,08421bb72ad8f0e7081d61ba8f28e686759f1acb@159.69.79.247:20656,a0dd817c68084e004c2afd39accded6d8d34f9cf@217.76.51.182:11656,5be198ab419cba96d1afafb798a5144179cd659e@65.109.65.248:32656,ad32f26daef9e39d3e8bdc713cdfda50c24e3ff6@194.163.134.164:16456,b04ba89c29ebb055b6c673aabbe84522dbc6fb62@135.181.98.42:31656,0b1ae20b6be9a94322e09f8a1018ef9fe190acf4@148.251.177.108:20656,7cd141e36d7792efb3e531a1782d2b801d334360@158.220.122.84:16456,c0e8d54513e0001a13fc2254d0a1f94adc0d249e@184.174.34.83:16456,24a6e408f94d432aae0ee4e21c78c5d8de3f8a52@109.123.255.50:31156,1016bb6d890ffafe49eb8b2264937bdbcd775135@46.4.5.45:20656,1f60d90e2d8d1eb75c3da6ed162ae044ef6d5dde@161.97.157.109:36659,1824bc086c43002fb80e153f4a6e6583443c6b0d@45.85.147.65:26656,a2975521fcef0f5be5dc67cf4e17455dc9028425@144.217.68.182:20656,584b6305b8437b90ea2e7421af4bdbb37ceb09c5@107.155.92.130:16456"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.babylond/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.babylond/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.babylond/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.babylond/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.babylond/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.babylond/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.babylond/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.babylond/config/config.toml

# create service
sudo tee /etc/systemd/system/babylond.service > /dev/null << EOF
[Unit]
Description=Babylon Network Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which babylond) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

babylond tendermint unsafe-reset-all --home $HOME/.babylond --keep-addr-book
curl -L https://snapshots.kjnodes.com/babylon-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.babylond

# start service
sudo systemctl daemon-reload
sudo systemctl enable babylond
sudo systemctl start babylond

break
;;

"Create Wallet")
babylond keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
BABYLON_WALLET_ADDRESS=$(babylond keys show $WALLET -a)
BABYLON_VALOPER_ADDRESS=$(babylond keys show $WALLET --bech val -a)
echo 'export BABYLON_WALLET_ADDRESS='${BABYLON_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export BABYLON_VALOPER_ADDRESS='${BABYLON_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
babylond tx checkpointing create-validator \
--amount 1000000ubbn \
--pubkey $(babylond tendermint show-validator) \
--moniker $NODENAME \
--chain-id bbn-test-2 \
--commission-rate 0.05 \
--commission-max-rate 0.20 \
--commission-max-change-rate 0.01 \
--min-self-delegation 1 \
--from wallet \
--gas-adjustment 1.4 \
--gas auto \
--fees 10ubbn \
-y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
