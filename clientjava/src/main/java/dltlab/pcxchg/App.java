package dltlab.pcxchg;

import org.apache.log4j.BasicConfigurator;
import org.hyperledger.fabric.sdk.*;
import org.hyperledger.fabric.sdk.exception.CryptoException;
import org.hyperledger.fabric.sdk.exception.InvalidArgumentException;
import org.hyperledger.fabric.sdk.exception.ProposalException;
import org.hyperledger.fabric.sdk.exception.TransactionException;
import org.hyperledger.fabric.sdk.security.CryptoSuite;

import java.security.PrivateKey;
import java.util.Collection;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;

public class App {
    public App() {
    }

    public void run() throws InvalidArgumentException, TransactionException, ProposalException, ExecutionException, InterruptedException, CryptoException {
        System.out.println("RUN APP");

        String filepath_pk = "/Users/vitalijreicherdt/BlockChain/Fabric/B9Lab/pcxchg/producerApp/certs/fec45fb2ed11bccb2e990c2ea180a7e8714a5cdb9f3be257629fa64b9241a8a6_sk";
        PrivateKey privateKey = KeyUtils.readPrivateKey(filepath_pk);

        String filepath_cert = "/Users/vitalijreicherdt/BlockChain/Fabric/B9Lab/pcxchg/producerApp/certs/Admin@Asus.com-cert.pem";
        String cert = KeyUtils.readPemCertificate(filepath_cert);
        TestUser testUser = new TestUser(privateKey, cert);

        //was missing in training documentation
        HFClient client = HFClient.createNewInstance();
        client.setCryptoSuite(CryptoSuite.Factory.getCryptoSuite());

        client.setUserContext(testUser);

        Peer asusPeer = client.newPeer("Asus", "grpc://localhost:7051");
        Orderer orderer = client.newOrderer("orderer", "grpc://localhost:7050");
        Channel channel0 = client.newChannel("asus");

        channel0.addOrderer(orderer);
        channel0.addPeer(asusPeer);

        channel0.initialize();

        //create and send transaction
        final TransactionProposalRequest proposalRequest = client.newTransactionProposalRequest();

        final ChaincodeID chaincodeID = ChaincodeID.newBuilder()
                .setName("pcxchg")
                .setVersion("1.0")
                .setPath("/Users/vitalijreicherdt/BlockChain/Fabric/B9Lab/pcxchg/chaincode/pcxchg")
                .build();

        // chaincode name
        proposalRequest.setChaincodeID(chaincodeID);
        // chaincode function to execute
        proposalRequest.setFcn("createPC");
        // timeout
        proposalRequest.setProposalWaitTime(60000);
        // arguments for chaincode function
        String[] args = { "Asus002", "foo", "bar" };
        proposalRequest.setArgs(args);

        // Sending transaction proposal
        final Collection<ProposalResponse> responses = channel0.sendTransactionProposal(proposalRequest);

        System.out.println("sending transaction");
        EventHub eventHub = client.newEventHub("test", "grpc://localhost:7053");
        channel0.addEventHub(eventHub);

        CompletableFuture<BlockEvent.TransactionEvent> txFuture = channel0.sendTransaction(responses, client.getUserContext());

        System.out.println("future done: " + txFuture.isDone());
        //TODO funzt nicht
        txFuture.thenAccept(s -> System.out.println("Computation returned: " + s));
        BlockEvent.TransactionEvent event = txFuture.get();
        System.out.println("event valid: " + event.isValid());
        event.getEventHub().shutdown();
    }

    public static void main(String ...ars) {
        App app = new App();
        try {
            //init logger
            BasicConfigurator.configure();
            app.run();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }
        System.exit(0);
    }
}
