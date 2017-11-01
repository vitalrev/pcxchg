# this script generates genesis block, channels tx and anchor tx
# configuration see in configtx.yaml

export FABRIC_CFG_PATH=./
export PATH=~/BlockChain/Fabric/B9Lab/samples/fabric-samples/bin:$PATH

configtxgen -profile PCXCHGOrdererGenesis -outputBlock ./orderer/genesis.block

configtxgen -profile AsusChannel -outputCreateChannelTx ./channels/Asus.tx -channelID asus
configtxgen -profile DellChannel -outputCreateChannelTx ./channels/Dell.tx -channelID dell
configtxgen -profile HPChannel -outputCreateChannelTx ./channels/HP.tx -channelID hp

configtxgen -profile AsusChannel -outputAnchorPeersUpdate ./channels/asusanchor.tx -channelID asus -asOrg AsusMSP
configtxgen -profile DellChannel -outputAnchorPeersUpdate ./channels/dellanchor.tx -channelID dell -asOrg DellMSP
configtxgen -profile HPChannel -outputAnchorPeersUpdate ./channels/hpanchor.tx -channelID hp -asOrg HPMSP