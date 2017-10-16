# Angular-Truffle 	
 ------------------------		

This project was developed  
with [Hyperledger Fabric](https://github.com/hyperledger/fabric) version 1.0.2.  
and node.js as client app.  
  
Write, compile & deploy and call chaincode for HLF.

## How to use
Than, there are 2 small parts to successfully running this project.

### Preparation

1. `git clone https://github.com/vitalrev/pcxchg.git`
2. In first terminal `cd producerApp`
3. `npm install`
4. `cp certs/fec45fb2ed11bccb2e990c2ea180a7e8714a5cdb9f3be257629fa64b9241a8a6_sk ~/.hfc-key-store/fec45fb2ed11bccb2e990c2ea180a7e8714a5cdb9f3be257629fa64b9241a8a6-priv`
5. In second terminal `cd marketApp`
6. `npm install`
7. `cp certs/892511a30be217ddc2ff439f650caad802b399ce43b903835d321ed3728fe246_sk ~/.hfc-key-store/892511a30be217ddc2ff439f650caad802b399ce43b903835d321ed3728fe246-priv`

### Start and initialize HLF Network

1. In third terminal `docker-compose -f docker-compose-pcxchg.yaml up`
2. In fourth terminal `./networkOld.sh`

### Start Client Apps
1. In first terminal (under producerApp) `node producerApp.js`  
   Test with GUI [`http://localhost:4000/`](http://localhost:4000/) or Curl (invoke createPC):  
   `curl -s -X POST  http://localhost:4000/invoke -H "content-type: application/json" -d '{"args":["Asus","Asus001","foo","bar"]}'`  
   See results with  
   `./query.sh`
2. In second terminal (under marketApp) `node marketApp.js`  
   Test with browser:  
   [`http://localhost:5000/API/queryStock?producer=Asus`](http://localhost:5000/API/queryStock?producer=Asus)  
   [`http://localhost:5000/API/queryDetails?producer=Asus&serial=Asus001`](http://localhost:5000/API/queryDetails?producer=Asus&serial=Asus001)  
   Buy PC with GUI:  
   [`http://localhost:5000/buyPC`](http://localhost:5000/buyPC)

### Test queries
`./query.sh`
