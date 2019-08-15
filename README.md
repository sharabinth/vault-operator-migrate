# Vault Storage Migration 
This repo is used to test the ```vault operator migrate``` command to copy existing vault data to a new vault cluster.
This repo has a vagrant file to create two enterprise (or OSS) Vault Clusters with Consul backend.  

Each cluster contains 2 nodes and each node consists of a Consul Server and Vault server.  
The configuration is used for learning purposes.  This is NOT following the reference architecture for Vault and should not be used for a Production setup.

The first cluster can be treated as an existing cluster to store the usual vault data.  The second cluster is treated as a new cluster which is not yet initialised.


All servers are set without TLS.

## Pre-Requisites
Create a folder named as ```ent``` and copy both the Consul and Vault enterprise binary zip files.  

```e.g., consul-enterprise_1.4.5+prem_linux_amd64.zip```

If using OSS binary zip file the make appropriate changes to the Vault and Consul setup shell scripts in the ```scripts``` folder.

## Vault Primary Cluster
2 node cluster is created with each node containing Vault and Consul servers. The server details are shown below

```
vault1   10.100.1.11
vault2   10.100.1.12
```

One of the Consul servers would become the leader.  Similarly one of Vault servers would become the Active node and the other node acts as Read Replica.

## Usage
If the ubuntu box is not available then it will take sometime to download the base box for the first time.  After the initial download, servers can be destroyed and recreated quickly with Vagrant

```
$vagrant up

$vagrant status

```

To check the status of the servers ssh into one of the nodes and check the cluster members and identify the leader.

```
$vagrant ssh vault1

vagrant@v1: $consul members

Node  Address           Status  Type    Build      Protocol  DC   Segment
v1    10.100.1.11:8301  alive   server  1.5.0+ent  2         dc1  <all>
v2    10.100.1.12:8301  alive   server  1.5.0+ent  2         dc1  <all>

vagrant@v1: $consul operator raft list-peers 

Node  ID                                    Address           State     Voter  RaftProtocol
v1    8c50f7de-634e-d7ee-17b8-7f904a34434d  10.100.1.11:8300  leader    true   3
v2    b3100f83-a4d1-89fd-5ab3-d96951e6a342  10.100.1.12:8300  follower  true   3

vagrant@v1: $consul info

vagrant@v1:~$ vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       1
Threshold          1
Unseal Progress    0/1
Unseal Nonce       n/a
Version            1.1.2+prem
HA Enabled         true

```

## Initialising and Unsealing Vault

Perform the following to initialise and unseal the Vault cluster.
Initialisation is only required at one of the servers.

Vault is initialised with unseal keys.  

```
$vagrant ssh vault1

vagrant@v1: $vault status

vagrant@v1:~$ vault operator init -key-shares=1 -key-threshold=1 > keys.txt
Unseal Key 1: JVlj1SkQF6F3+35mvu8HyeukOyYxptK5/1lCv2OgUiM=

Initial Root Token: s.scWMexn7hrCoAxIF54KBleEj

Vault initialized with 1 key shares and a key threshold of 1. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 1 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 1 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.

vagrant@v1:~$ vault status
Key                Value
---                -----
Seal Type          shamir
Initialized        true
Sealed             true
Total Shares       1
Threshold          1
Unseal Progress    0/1
Unseal Nonce       n/a
Version            1.1.2+prem
HA Enabled         true

vagrant@v1:~$ vault operator init

vagrant@v1:~$ vault operator unseal
Unseal Key (will be hidden):
Key                    Value
---                    -----
Seal Type              shamir
Initialized            true
Sealed                 false
Total Shares           1
Threshold              1
Version                1.1.2+prem
Cluster Name           vault-cluster-daba87a2
Cluster ID             8d3e8616-8b28-a7fb-93e1-126810b27f2e
HA Enabled             true
HA Cluster             n/a
HA Mode                standby
Active Node Address    <none>

vagrant@v1:~$ vault status
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    1
Threshold       1
Version         1.1.2+prem
Cluster Name    vault-cluster-daba87a2
Cluster ID      8d3e8616-8b28-a7fb-93e1-126810b27f2e
HA Enabled      true
HA Cluster      https://10.100.1.11:8201
HA Mode         active
Last WAL        16

vagrant@v1: $exit

$vagrant ssh vault2

vagrant@v2: $ vault operator unseal
vagrant@v2: $ vault status

```

## Accessing UI

Use one of the server nodes to access the Consul UI on port 8500 and the Vault UI on port 8200.  The UI for Consul will not work if the leader is not elected.

e.g., Consul UI http://10.100.1.11:8500 

e.g., Vault UI http://10.100.2.11:8500 

## Enter Data
Add plenty data to the Primary vault cluster.  This is to simulate an existing cluster with data.

## Vault Secondary Cluster
This cluster is treated as a new Vault cluster to receive the migrated data.  2 node cluster is created with each node containing Vault and Consul servers. The server details are shown below

```
vault1   198.100.1.13
vault2   198.100.1.14
```

Do not initialise this cluster. SSH into both vault nodes and check ```vault status``` and ```consul members```.

## Migrate Data

SSH into the Primary vault cluster i.e., the existing cluster and issue the migrate command to move the data.

```
vagrant@v1:~$ vault operator migrate -config migrate.hcl
```

Once the data is migrated the new cluster will be shown as initialised but as sealed. Use the unseal key of the existing cluster to unseal the new cluster.

## Check Migrated Data

Check the contents such as secrets, auth backends, policies, tokens, namespaces etc by using either CLI or UI.  For UI, use the IP address of the secondary cluster.

## Clean Up

Use ```vagrant destroy``` and answer ```Y``` to destroy each VM machine

