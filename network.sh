#!/bin/bash
# Copyright London Stock Exchange Group All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
set -e

echo "create channels"
docker exec cli.Amazon bash -c 'peer channel create -c asus -f ./channels/Asus.tx -o orderer.pcxchg.com:7050'
docker exec cli.Amazon bash -c 'peer channel create -c dell -f ./channels/Dell.tx -o orderer.pcxchg.com:7050'
docker exec cli.Amazon bash -c 'peer channel create -c hp -f ./channels/HP.tx -o orderer.pcxchg.com:7050'

sleep 3

echo "join amazon to channels"
docker exec cli.Amazon bash -c 'peer channel join -b asus.block'
docker exec cli.Amazon bash -c 'peer channel join -b dell.block'
docker exec cli.Amazon bash -c 'peer channel join -b hp.block'

echo "join producer to channels"
docker exec cli.Asus bash -c 'peer channel join -b asus.block'
docker exec cli.HP bash -c 'peer channel join -b hp.block'
docker exec cli.Dell bash -c 'peer channel join -b dell.block'

echo "update channels"
docker exec cli.Asus bash -c 'peer channel update -o orderer.pcxchg.com:7050 -c asus -f ./channels/asusanchor.tx'
docker exec cli.Dell bash -c 'peer channel update -o orderer.pcxchg.com:7050 -c dell -f ./channels/dellanchor.tx'
docker exec cli.HP bash -c 'peer channel update -o orderer.pcxchg.com:7050 -c hp -f ./channels/hpanchor.tx'

sleep 3

echo "install chaincode"
docker exec cli.Asus bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'
docker exec cli.HP bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'
docker exec cli.Dell bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'
docker exec cli.Amazon bash -c 'peer chaincode install -p pcxchg -n pcxchg -v 0'

echo "instantiate chaincode"
docker exec cli.Asus bash -c "peer chaincode instantiate -C asus -n pcxchg -v 0 -c '{\"Args\":[]}'"
docker exec cli.HP bash -c "peer chaincode instantiate -C hp -n pcxchg -v 0 -c '{\"Args\":[]}'"
docker exec cli.Dell bash -c "peer chaincode instantiate -C dell -n pcxchg -v 0 -c '{\"Args\":[]}'"