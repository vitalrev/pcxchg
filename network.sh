#!/bin/bash
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
set -e
# This script expedites the chaincode development process by automating the
# requisite channel create/join commands

# We use a pre-generated orderer.block and channel transaction artifact (myc.tx),
# both of which are created using the configtxgen tool

# first we create the channel against the specified configuration in myc.tx
# this call returns a channel configuration block - myc.block - to the CLI container
echo "create channels"
docker exec cli.Amazon bash -c 'peer channel create -c asus -o orderer.pcxchg.com:7050 -f ./channels/Asus.tx'
docker exec cli.Amazon bash -c 'peer channel create -c dell -o orderer.pcxchg.com:7050 -f ./channels/Dell.tx'
docker exec cli.Amazon bash -c 'peer channel create -c hp -o orderer.pcxchg.com:7050 -f ./channels/HP.tx'

sleep 3

# now we will join the channel and start the chain with myc.block serving as the
# channel's first block (i.e. the genesis block)
echo "join amazon to channels"
docker exec cli.Amazon bash -c 'peer channel join -b asus.block'
docker exec cli.Amazon bash -c 'peer channel join -b dell.block'
docker exec cli.Amazon bash -c 'peer channel join -b hp.block'

sleep 3

# first join to channels
echo "join others to channels"
docker exec cli.Asus bash -c 'peer channel join -b asus.block'
docker exec cli.HP bash -c 'peer channel join -b hp.block'
docker exec cli.Dell bash -c 'peer channel join -b dell.block'

# now update channels
echo "update channels"
docker exec cli.Asus bash -c 'peer channel update -o orderer.pcxchg.com:7050 -c asus -f ./channels/asusanchor.tx'
docker exec cli.Dell bash -c 'peer channel update -o orderer.pcxchg.com:7050 -c dell -f ./channels/dellanchor.tx'
docker exec cli.HP bash -c 'peer channel update -o orderer.pcxchg.com:7050 -c hp -f ./channels/hpanchor.tx'

sleep 3

# Now the user can proceed to build and start chaincode in one terminal
# And leverage the CLI container to issue install instantiate invoke query commands in another
# install on each peer:
echo "install chaincode"
docker exec cli.Asus bash -c 'peer chaincode install -p producer -n producer -v 0'
docker exec cli.HP bash -c 'peer chaincode install -p producer -n producer -v 0'
docker exec cli.Dell bash -c 'peer chaincode install -p producer -n producer -v 0'

docker exec cli.Amazon bash -c 'peer chaincode install -p producer -n producer -v 0'
docker exec cli.Amazon bash -c 'peer chaincode install -p market -n market -v 0'

# old stuff
#docker exec cli.Asus bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'
#docker exec cli.HP bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'
#docker exec cli.Dell bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'
#docker exec cli.Amazon bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'

#instantiate the chaincode on each channel:
echo "instantiate chaincode"
docker exec cli.Asus bash -c "peer chaincode instantiate -C asus -n producer -v 0 -c '{\"Args\":[]}'"
docker exec cli.HP bash -c "peer chaincode instantiate -C hp -n producer -v 0 -c '{\"Args\":[]}'"
docker exec cli.Dell bash -c "peer chaincode instantiate -C dell -n producer -v 0 -c '{\"Args\":[]}'"

docker exec cli.Amazon bash -c "peer chaincode instantiate -C asus -n market -v 0 -c '{\"Args\":[]}'"
docker exec cli.Amazon bash -c "peer chaincode instantiate -C hp -n market -v 0 -c '{\"Args\":[]}'"
docker exec cli.Amazon bash -c "peer chaincode instantiate -C dell -n market -v 0 -c '{\"Args\":[]}'"

# old stuff
#docker exec cli.Asus bash -c "peer chaincode instantiate -C asus -n pcxchg -v 0 -c '{\"Args\":[]}'"
#docker exec cli.HP bash -c "peer chaincode instantiate -C hp -n pcxchg -v 0 -c '{\"Args\":[]}'"
#docker exec cli.Dell bash -c "peer chaincode instantiate -C dell -n pcxchg -v 0 -c '{\"Args\":[]}'"

#we should have bailed if above commands failed.
#we are here, so they worked
#sleep 60000
exit 0
