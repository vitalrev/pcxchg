'use strict'; // self-defence

// Functions from figure
const hfc = require('fabric-client');
let channel;
const enrolUser = function(client, options) {
  return hfc.newDefaultKeyValueStore({ path: options.wallet_path })
    .then(wallet => {
      client.setStateStore(wallet);
      return client.getUserContext(options.user_id, true);
    });
};

const initNetwork = function(client, options, target) {
  let channel;
  try {
    channel = client.newChannel(options.channel_id);
    const peer = client.newPeer(options.peer_url);
    target.push(peer);
    channel.addPeer(peer);
    channel.addOrderer(client.newOrderer(options.orderer_url));
  } catch(e) { // channel already exists
    channel = client.getChannel(options.channel_id);
  }
  return channel;
};

const transactionProposal = function(client, channel, request) {
    request.txId = client.newTransactionID();
    return channel.sendTransactionProposal(request);
};

const responseInspect = function(results) {
const proposalResponses = results[0];
const proposal = results[1];
const header = results[2];

if (proposalResponses && proposalResponses.length > 0 &&
    proposalResponses[0].response &&
    proposalResponses[0].response.status === 200) {
    return true;
}
return false;
};

const sendOrderer = function(channel, request) {
    return channel.sendTransaction(request);
};

const target = [];
const client = new hfc();

function invoke(opt, param, request) {
return enrolUser(client, opt)
    .then(user => {
        if(typeof user === "undefined" || !user.isEnrolled())
            throw "User not enrolled";

        channel = initNetwork(client, opt, target);
        request.targets = target;
        request.chaincodeId = opt.chaincode_id;
        request.chainId = opt.channel_id;
        request.args = param;
        request.txId = client.newTransactionID();
        return transactionProposal(client, channel, request);
    })
    .then(results => {
        if (responseInspect(results)) {
            const request = {
                proposalResponses: results[0],
                proposal: results[1],
                header: results[2]
            };
            return sendOrderer(channel, request);
        } else {
            throw "Response is bad";
        }
    })
    .catch(err => {
        console.log(err);
        throw err;
    });
};

const query = function(opt, param, request) {
    return enrolUser(client, opt)
      .then(user => {
        if(typeof user === "undefined" || !user.isEnrolled()) {
          throw "User not enrolled";
        }
        channel = initNetwork(client, opt, target);
        request.chaincodeId = opt.chaincode_id;
        request.chainId = opt.channel_id;
        request.args = param;
        request.txId = client.newTransactionID();
        return channel.queryByChaincode(request);
      })
      .then(queryResponses => {
        const result=[];
  
        for(let i = 0; i < queryResponses.length; i++) {
          result.push( queryResponses[i].toString('utf8') );
        }
  
        return JSON.stringify({ result });
      })
      .catch(err => {
        console.log(err);
        throw err;
      });
};

// Options
const options = {
    Asus : {
      wallet_path: '/Users/vitalijreicherdt/BlockChain/Fabric/B9Lab/pcxchg/marketApp/certs',
      user_id: 'AmazonAdmin',
      channel_id: 'asus',
      chaincode_id: 'pcxchg',
      peer_url: 'grpc://localhost:8051',
      orderer_url: 'grpc://localhost:7050'
    },
    Hp : {
      wallet_path: '/Users/vitalijreicherdt/BlockChain/Fabric/B9Lab/pcxchg/marketApp/certs',
      user_id: 'AmazonAdmin',
      channel_id: 'hp',
      chaincode_id: 'pcxchg',
      peer_url: 'grpc://localhost:8051',
      orderer_url: 'grpc://localhost:7050'
    },
    Dell : {
      wallet_path: '/Users/vitalijreicherdt/BlockChain/Fabric/B9Lab/pcxchg/marketApp/certs',
      user_id: 'AmazonAdmin',
      channel_id: 'dell',
      chaincode_id: 'pcxchg',
      peer_url: 'grpc://localhost:8051',
      orderer_url: 'grpc://localhost:7050'
    }
};

const requests = {
    buyPC: {
      targets: null,
      chaincodeId: null,
      fcn: 'buyPC',
      args: null,
      chainId: null,
      txId: null
    },
    queryDetail: {
      targets: null,
      chaincodeId: null,
      fcn: 'queryDetail',
      args: null,
      chainId: null,
      txId: null
    },
    queryStock: {
      targets: null,
      chaincodeId: null,
      fcn: 'queryStock',
      args: null,
      chainId: null,
      txId: null
    }
};

// Server
const express = require("express");
const app = express();
const http = require('http');
const bodyParser = require('body-parser');
const path = require('path');
var serverPort = 5000;

app.engine('html', require('ejs').renderFile);

const server = http.createServer(app).listen(serverPort, function() {
    console.log('Your server is listening on port %d (http://localhost:%d)', serverPort, serverPort);
});
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(__dirname));
app.set('views', __dirname);

app.post('/buyPC/invoke', function(req, res, next) {
  const args = req.body.args;
  invoke(options[args[0]], args.slice(1), requests["buyPC"])
    .then(() => res.send("Chaincode invoked"))
    .catch(err => {
      res.status(500);
      res.send(err.toString());
    });
});

app.get('/buyPC', function(req, res) {
  res.render('buyPC.html');
});

app.get('/API/queryStock', function(req, res,next) {
  query(options[req.query.producer], [''], requests["queryStock"])
    .then(result => res.json(result))
    .catch(err => {
      res.status(500);
      res.send(err.toString());
    });
});

app.get('/API/queryDetails', function(req, res, next) {
  query(
      options[req.query.producer],
      [ req.query.serial.toString() ],
      requests[ "queryDetail" ])
    .then(result => res.json(result))
    .catch(err => {
      res.status(500);
      res.send(err.toString());
    });
});