package dltlab.pcxchg;

import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;

import java.io.FileReader;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.PrivateKey;
import java.security.Security;

public class KeyUtils {
    public static String readPemCertificate(String filepath) {
        try {
            return new String(Files.readAllBytes(Paths.get(filepath)));
        } catch (Exception e) {
            System.out.println("exception");
            e.printStackTrace();
            return null;
        }
    }

    // read PKCS#1 key
    public static PrivateKey readPrivateKey(String filepath)  {
        try {
            Security.addProvider(new BouncyCastleProvider());
            PEMParser pemParser = new PEMParser(new FileReader(filepath));
            JcaPEMKeyConverter converter = new JcaPEMKeyConverter().setProvider("BC");
            PrivateKey privateKey = converter.getPrivateKey((PrivateKeyInfo) pemParser.readObject()); //kp.getPrivate();

            System.out.println("read key:");
            System.out.println(privateKey);
            return privateKey;
        } catch (Exception e) {
            System.out.println("exception");
            e.printStackTrace();
            return null;
        }
    }
}
