package dltlab.pcxchg;

import org.hyperledger.fabric.sdk.Enrollment;
import org.hyperledger.fabric.sdk.User;

import java.security.PrivateKey;
import java.util.Set;

public class TestUser implements User {
    private final PrivateKey privateKey;
    private final String cert;

    public TestUser(PrivateKey privateKey, String cert) {
        this.privateKey = privateKey;
        this.cert = cert;
    }

    @Override
    public String getAccount() {
        return null;
    }

    @Override
    public String getAffiliation() {
        return null;
    }

    @Override
    public Enrollment getEnrollment() {
        PrivateKey _privateKey = this.privateKey;
        String _cert = this.cert;

        return new Enrollment() {
            @Override
            public PrivateKey getKey() {
                return _privateKey;
            }

            @Override
            public String getCert() {
                return _cert;
            }
        };
    }

    @Override
    public String getName() {
        return "AsusAdmin";
    }

    @Override
    public Set<String> getRoles() {
        return null;
    }

    @Override
    public String getMspId() {
        return "AsusMSP";
    }
}
