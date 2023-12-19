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
make install

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
PEERS="7e2c922b8281f7db344c4005dcbf395ad123f01c@194.163.179.176:26656,3287ddbe454cfb5a162799b468c1405b7370c541@95.217.199.12:26601,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:16456,6f55a3138d18e8c0eaa66e347794428db698bf2a@148.251.176.236:2000,0295d6008b49a9bcd750cded7600128c7c440bc2@176.57.150.156:16456,c92746c74a284b2da46e8b1f9889f528be8513e0@109.123.253.200:16456,60d1efa51e8a9d873e7eba1585218ada92bf8787@161.97.97.239:16456,74cea3a74157ba5e75bb533bbed5bae93d042405@75.119.158.40:16456,8bdb48cd7118c3c6eda2f7a729a31a84b4acb24b@164.68.104.45:16456,d39ffcbfdc7c9481009b87848bdca29abee24156@161.97.121.15:16456,0aa00ec743387133e0d7f6fdd053c1ca712827b8@109.123.241.147:16456,a0f32c27dc09c2c9e0d925f3b9c2c23a6202e847@84.46.243.251:16456,65ed81de929f8b5d31b254169ad13f74dda06c78@161.97.79.174:16456,797815099f6b1443c7e662fd28410696bfecd0fa@185.188.249.83:16456,f7069ece5da9dc3ef498b4d5484aef55ad008fde@88.99.192.216:16456,2845e9d16d9d9ae5f03a25e2ab906303d74b05d8@62.171.157.254:16456,04260c47d5aeeeff8539f583daf5478191e4767c@144.91.115.224:16456,8d4be0569eb316fb3b75642ad0ad31e1e8538524@167.86.127.67:16456,83b89eadb9341e79ef8a61e605c453a2eebf138d@79.80.135.149:26766,e2cf68fd035fe82f3a2615e375d2e9225fddc2e8@62.171.188.158:16456,775ff9730831dc794eb4412e1ef1ac0e0a28dc26@95.111.229.105:16456"
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
curl https://snapshots-testnet.nodejumper.io/babylon-testnet/babylon-testnet_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.babylond

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
