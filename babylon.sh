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
cd && rm -rf babylon
git clone https://github.com/babylonchain/babylon
cd babylon
git checkout v0.7.2
make install

# config
babylond config chain-id $BABYLON_CHAIN_ID
babylond config keyring-backend test

# init
babylond init $NODENAME --chain-id $BABYLON_CHAIN_ID

# download genesis and addrbook
curl -L https://snapshots-testnet.nodejumper.io/babylon-testnet/genesis.json > $HOME/.babylond/config/genesis.json
curl -L https://snapshots-testnet.nodejumper.io/babylon-testnet/addrbook.json > $HOME/.babylond/config/addrbook.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.001ubbn\"/" $HOME/.babylond/config/app.toml

# set peers and seeds
SEEDS=""
PEERS="5397e85ae65c75f739fa80b6a752762567a68a16@154.42.7.100:26656,59e8dad44f964821186962c60b5f2ac70585b31c@154.42.7.186:26656,59f28e3c87ba3ab7803a328304adebfc07cfe3e2@154.42.7.86:26656,b19b98d8be060a8979b68413c5af19e1a735178f@154.42.7.126:26656,36a93fae1cf2343e6497822366b48cbc8de5f322@84.247.185.173:26656,34ce32c340ee34fb1dce5bf6db3f6bd7bbfe9e74@89.117.58.67:26656,0123d9c8840ef3c9f8b966525bf9ab48012fd29d@65.108.129.239:40656,d26afeffcebda71924f4bd33f80b6c2876b10b17@38.242.134.68:16456,66886aae0323cee9467a5b2bd6dec33899a7ef1c@154.42.7.36:26656,118a68dbb190bec1b9882ef27c0edb5af79a052e@104.248.198.47:31156,51314f182689b204c314f9c0fda2e82a7daa6666@95.111.238.104:16456,e2adf7d3f26eb2d6eb79401e8c5baf7d20e29332@37.60.239.42:16456,2cb43acf848505af4a1ae10d14df84dce9ec89c4@154.42.7.137:26656,81c65a4e86fef50c88b372da7fe50acefff7a779@167.86.126.201:26656,dadf0fdf7d24ad2427237abbce3f39be8b3d438f@37.60.235.250:16456,39b8c9adc8801d5c2b444fe7145860eb04bbc9ec@65.108.59.77:31156,6fac98af2cb8af1fe21d9736d55433e9cc294a1e@37.60.251.114:26656,09ad2c93fe84ebf93ce28e43b290fa3b9f3bbf24@161.97.72.103:16456,661631418c529d0080814510627213f0e297d59c@89.117.51.136:16456,2fb643493b8ebe450df69758b48c9ff0024e8acc@184.174.34.61:16456,823233adfd89468327f420e20fc213ca3688fb8e@37.60.248.39:16456,78006719f5edc7da96f4c751bb9c260708a04cc3@158.220.97.112:16456,de7a6e0a5338086ceea92bb35e2597d06155c65a@154.42.7.76:26656,84b6e369a271ddf70b7e0922abfe603809769b8b@35.188.47.245:16456,e37a883d7e1175096dba08a268e7cbe0066476e7@109.123.244.160:16456,c9c67bb3a27642a4c4486394f281fc7262c2b91a@65.109.27.66:16456,33a0b44ffd451e595b1009ed41f36e39cd7b9614@149.102.142.183:26656,11f1acaea12cf1dfcd0c8a38fda609374137c5da@37.60.250.69:26656,3bc588a04c37b237c9232bb96f44da49ae7477a3@154.42.7.105:26656,ea6e8374c3ff2603d535d2648d963b76bd4fd314@109.123.242.32:26656,1d6f92199ea41f386ea07bb48372eaf411a2612f@62.171.133.146:16456,f43ad13231d17e882c4ecd8d66455d400b6b33ad@37.60.249.251:26656,6487620e16fe352eed9912c151bcb956def57a68@37.60.249.252:26656,c941ae3226e8b2155f5edd252579b469dfbc2ac9@188.68.40.79:26656,a24220688be9fd8391a59fac064a202a54f5d2ad@84.247.169.225:16456,e20de6b485233509f9cca43ee4f01002661bd5a1@37.60.239.44:16456,16f033e6a8ee599948f2ab9349899ef2bbded61a@65.109.70.45:27656,1953aedc99fbe5e2704e3a308eaccdeb4aec7c6f@194.163.149.73:16456,55f235c372ab1a4253d52c26afbef5ef59cd62d6@37.60.228.189:26656,ccbc596ca986f45eb32d45b47c46c7300a1064dc@154.42.7.49:26656,0145f790c613115eab414a88f49af52c21513137@185.187.170.244:26656,4afa7a82cb264892491eb6f9a1953adddd98d9b7@154.42.7.190:26656,e4278dc3dbfe19690ea9038c9b327270fcaee347@161.97.171.63:26656,cb4a34bd5443fe7f0dce957d3811c2fa8908d5e9@154.42.7.47:26656"
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
Description=Babylon node service
After=network-online.target
[Service]
User=$USER
ExecStart=$(which babylond) start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
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
