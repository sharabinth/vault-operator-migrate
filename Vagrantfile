# -*- mode: ruby -*-
# vi: set ft=ruby :

### Define environment variables to pass on to provisioner

# Define Vault Primary HA cluster details.  This is to simulate an existing cluster where
# Vault will be used to store the credentials.  This data will be migrated to a newly created Secondary HS cluster.
VAULT_HA_SERVER_IP_PREFIX = ENV['VAULT_HA_SERVER_IP_PREFIX'] || "10.100.1.1"
VAULT_HA_SERVER_IPS = ENV['VAULT_HA_SERVER_IPS'] || '"10.100.1.11", "10.100.1.12"'

# Define Vault Secondary HA cluster details.  Data will be migrated from an existing primary cluster to this new secondary
# cluster using the operator migrate command.  
VAULT_HA_SEC_SERVER_IP_PREFIX = ENV['VAULT_HA_SEC_SERVER_IP_PREFIX'] || "198.100.1.1"
VAULT_HA_SEC_SERVER_IPS = ENV['VAULT_HA_SEC_SERVER_IPS'] || '"198.100.1.13", "198.100.1.14"'


Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_version = "20190411.0.0"

  # Consul UI for Primary would be available at port 8500 and can be accessed from any of the servers e.g., http://10.100.1.11:8500 
  # UI will only work if a leader is elected successfully
  # Vault UI for Primary will be available at port 8200 and can be accessed from any of the primary servers e.g., http://10.100.1.11:8200

  # Set up the 2 node Vault Primary HA cluster servers.  Each node will have a Consul server and a Vault server.
  # This is not recommended for Prod as separate Consul servers and Vault Server + Consul Client are required for Prod setup.
  (1..2).each do |i|
    config.vm.define "vault#{i}" do |v1|
      v1.vm.hostname = "v#{i}"
      
      v1.vm.network "private_network", ip: VAULT_HA_SERVER_IP_PREFIX+"#{i}"
      v1.vm.provision "shell", 
              path: "scripts/setupConsulServer.sh",
              env: {'VAULT_HA_SERVER_IPS' => VAULT_HA_SERVER_IPS, 'VAULT_DC' => 'dc1'}

      v1.vm.provision "shell", 
              path: "scripts/setupVaultServer.sh"
    end
  end

  # Consul UI for Secondary would be available at port 8500 and can be accessed from any of the servers e.g., http://198.100.1.13:8500 
  # UI will only work if a leader is elected successfully
  # Vault UI for Secondary will be available at port 8200 and can be accessed from any of the primary servers e.g., http://198.100.1.13:8200

  # Set up the 2 node Vault Primary HA cluster servers.  Each node will have a Consul server and a Vault server.
  # This is not recommended for Prod as separate Consul servers and Vault Server + Consul Client are required for Prod setup.
  (3..4).each do |i|
    config.vm.define "vault#{i}" do |v1|
      v1.vm.hostname = "v#{i}"
      
      v1.vm.network "private_network", ip: VAULT_HA_SEC_SERVER_IP_PREFIX+"#{i}"
      v1.vm.provision "shell", 
              path: "scripts/setupConsulServer.sh",
              env: {'VAULT_HA_SERVER_IPS' => VAULT_HA_SEC_SERVER_IPS, 'VAULT_DC' => 'dc1'}

      v1.vm.provision "shell", 
              path: "scripts/setupVaultServer.sh"
    end
  end
end
