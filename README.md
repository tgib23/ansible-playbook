# ansible for linux dev

This playbook is for creating MapR cluster.
I hope this will be another re-invention of mapr-installer.

## Preparation
* install ansible-playbook
* ssh login to each node by root user without password
* modify /etc/hosts
* modify 'hosts' file in the root directory. 
```
[centos7]
node0 ansible_user=root
node1 ansible_user=root
node2 ansible_user=root

[hivemeta]
node2 ansible_user=root

[hiveserver2]
node2 ansible_user=root

[hive]
node2 ansible_user=root
```

## centos7 role

This role installs mapr-core packages assuming the node is centos7.
Parameters below is necessary.

| Parameters | Explanation |
|:-----------|:------------|
| cldb_nodes | comma separated nodes list |
| mapruser_password |  Encrypted password for mapr user. Encrypted password for mapr user. Install passlib and execute ```python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.using(rounds=5000).hash(getpass.getpass())"``` will give you the encrypted passwd  |
| zookeeper_nodes |   comma separated nodes list |
| cluste_name |   cluster name |
| clush_nodes |   space separated nodes list to setup clustershell |
| diskadd |   When you run this role for the first time, disk should be added to the cluster, so "diskadd" should be "yes". When you run after that, disk should not be added anymore, so "diskadd" should be "no" |
| mapr_version | mapr version to install |



Also, roles/centos7/files/disks have to be specified following your env
```
/dev/sdb
/dev/sdc
/dev/sdd
```

Then, you should be able to execute ansible with extra vars. See the sample below.
```
 ansible-playbook -i hosts site.yml --limit centos7 \
   --extra-vars '{ "clush_nodes":"node0 node1 node2", \
   "diskadd":"yes", "mapr_version":"5.2.0", "cldb_nodes":"node0,node1,node2", \
   "zookeeper_nodes":"node0:5181,node1:5181,node2:5181", "cluster_name":"sample", \
   "mapruser_password":"ENCRYPTED_PASSWORD"}'
```

you should be able to access MCS (ex. https://node0:8443/) now. Set the license.


## hivemeta role

hivemeta role installs mysqldb/mariadb, hivemeta and setup hivemeta.
parameters below are necessary.
* hive_password
    * This role assumes hivemeta and hiveserver uses user "hive" for mysqldb/mariadb. This parameter is for the password of this user.
* zookeeper_nodes
    * zookeeper nodes for dynamic service discovery
* hivemeta
    * node to install hivemeta

```
 ansible-playbook -i hosts site.yml --limit hivemeta --extra-vars '{ "clush_nodes":"node0 node1 node2", "diskadd":"yes", "mapr_version":"5.2.0", "cldb_nodes":"node0,node1,node2", "zookeeper_nodes":"node0:5181,node1:5181,node2:5181", "cluster_name":"sample", "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0", "hive_password":"hive", "hivemeta":"node2"}'
```

## hiveserver2 role

hiveserver2 role installs hiveserver2 and setup configuration.
This role configures hiveserver to [enable impersonation](http://maprdocs.mapr.com/home/Hive/HiveUserImpersonation-Enable.html)

parameters below are necessary.
* zookeeper_nodes
    * zookeeper nodes for dynamic service discovery
* hivemeta
    * node to install hivemeta

## hive role

hive role installs hive and setup configuration

parameters below are necessary.
* zookeeper_nodes
    * zookeeper nodes for dynamic service discovery
* hivemeta
    * node to install hivemeta

