docker exec cli.Amazon bash -c "peer chaincode invoke -C dell -n pcxchg -v 0 -c '{\"Args\":[\"buyPC\", \"Dell001\"]}'"

docker exec cli.Amazon bash -c "peer chaincode invoke -C asus -n pcxchg -v 0 -c '{\"Args\":[\"buyPC\", \"Asus001\"]}'"
