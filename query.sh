docker exec cli.Amazon bash -c "peer chaincode query -C asus -n pcxchg -v 0 -c '{\"Args\":[\"queryStock\"]}'"
docker exec cli.Amazon bash -c "peer chaincode query -C hp -n pcxchg -v 0 -c '{\"Args\":[\"queryStock\"]}'"
docker exec cli.Amazon bash -c "peer chaincode query -C dell -n pcxchg -v 0 -c '{\"Args\":[\"queryStock\"]}'"