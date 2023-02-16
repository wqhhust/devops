import jenkins.model.*
import hudson.security.*
import jenkins.model.Jenkins
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import com.cloudbees.plugins.credentials.CredentialsScope

File disableScript = new File(Jenkins.get().getRootDir(), ".disable-create-admin-user")
if (disableScript.exists()) {
    return
}

def instance = Jenkins.get()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin','admin_password')

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)

instance.setSecurityRealm(hudsonRealm)
instance.setAuthorizationStrategy(strategy)
instance.save()
disableScript.createNewFile()


File disableScript = new File(Jenkins.get().getRootDir(), ".disable-create-vagrant-userpass-credential")
if (disableScript.exists()) {
    return
}

instance = Jenkins.get()
domain = Domain.global()
store = instance.getExtensionList("com.cloudbees.plugins.credentials.SystemCredentialsProvider")[0].getStore()

usernameAndPassword = new UsernamePasswordCredentialsImpl(
  CredentialsScope.GLOBAL,
  "test",
  "a user to test",
  "test",
  "test_password",
)

store.addCredentials(domain, usernameAndPassword)
instance.save()
disableScript.createNewFile()
