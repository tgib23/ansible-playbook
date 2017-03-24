# ansible for MapR cluster setup

This playbook is for creating MapR cluster.
I hope this will be another re-invention of mapr-installer.

## Requirement

* I confirmed it works for CentOS 6 and 7 with MapR 5.2.0
* This ansible playbook assumes each node has the same disk setup for MFS, which means that if one node uses /dev/sdb,/dev/sdc,/dev/sdd then, other nodes also use the same disk path for MFS

## Preparation
* install ansible-playbook
* hostname has to be setup manually on cluster nodes
    * If you are using CentOS 6, you should edit /etc/sysconfig/network
	* If you are using CentOS 7, you should edit /etc/hostname
* ssh login to each node by root user without password
* modify 'hosts' file in the root directory. 
```
[core_centos7]
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
* edit roles/common/files/hosts, which will be copied to /etc/hosts of your cluster nodes, in case you use /etc/hosts to solve IP-Hostname.

## Role
### common

This role is applied to any nodes.
Parameters below have to be specified.

| Parameters | Explanation |
|:-----------|:------------|
| mapruser_password |  Encrypted password for mapr user. Install passlib and execute ```python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.using(rounds=5000).hash(getpass.getpass())"``` will give you the encrypted passwd  |
| use_hosts | If you use /etc/hosts to resolve IP-Hostname of your cluster, you should write those relations in roles/common/files/hosts, and then, use "use_hosts" parameter and say "yes". |
| mapr_version | mapr version to install. Ex. '5.2.0' |
| mep_version | mep version to install. Ex. '2.0' |

### core_centos7

This role installs mapr-core packages assuming the node is centos7.
Parameters below is necessary.

| Parameters | Explanation |
|:-----------|:------------|
| clush_nodes |   space separated nodes list to setup clustershell |




Then, you should be able to execute ansible with extra vars. See the sample below.
```
$ ansible-playbook -i hosts site.yml --limit core_centos7 \
   --extra-vars '{ "clush_nodes":"node0 node1 node2", \
   "add_disk":"yes", "mapr_version":"5.2.0", "cldb_nodes":"node0,node1,node2", \
   "zookeeper_nodes":"node0:5181,node1:5181,node2:5181", "cluster_name":"sample", \
   "mapruser_password":"ENCRYPTED_PASSWORD"}'
```


### webserver

This role adds the role of MCS to cluster node.

### resourcemanager & nodemanager

These roles adds the role of RM and NM to cluster nodes.

### hivemeta

hivemeta role installs mysqldb/mariadb, hivemeta and setup hivemeta.
parameters below are necessary.

| Parameters | Explanation |
|:-----------|:------------|
|hive_password | This role assumes hivemeta and hiveserver uses user "hive" for mysqldb/mariadb. This parameter is for the password of this user. |
|zookeeper_nodes | zookeeper nodes for dynamic service discovery. csv style |
| hivemeta | node to install hivemeta |
| db | "mysqldb" or "mariadb". default db of centos6 is mysqldb and centos7 is mariadb |

```
$ ansible-playbook -i hosts site.yml --limit hivemeta \
  --extra-vars '{ "clush_nodes":"node0 node1 node2", "add_disk":"no", \
  "mapr_version":"5.2.0", "cldb_nodes":"node0,node1,node2", \
  "zookeeper_nodes":"node0:5181,node1:5181,node2:5181", "cluster_name":"sample", \
  "mapruser_password":"ENCRYPTED_PASSWORD", "hive_password":"hive", "hivemeta":"node2"}'
```

### hiveserver2

hiveserver2 role installs hiveserver2 and setup configuration.
This role configures hiveserver to [enable impersonation](http://maprdocs.mapr.com/home/Hive/HiveUserImpersonation-Enable.html)
Parameters below have to be specified.

| Parameters | Explanation |
|:-----------|:------------|
|zookeeper_nodes | zookeeper nodes for dynamic service discovery. csv style |
| hivemeta | node to install hivemeta |

### hive

hive role installs hive and setup configuration
Parameters below have to be specified.

| Parameters | Explanation |
|:-----------|:------------|
|zookeeper_nodes | zookeeper nodes for dynamic service discovery. csv style |
| hivemeta | node to install hivemeta |


### config

This role executes configure.sh on each node.
Parameters below have to be specified.

| Parameters | Explanation |
|:-----------|:------------|
| cldb_nodes | comma separated list of cldb nodes. Ex "node0,node1,node2" |
| zookeeper_nodes |   comma separated nodes list |
| cluste_name |   cluster name |

### rerun_warden

This role executes disksetup and restart warden on each node.
Parameters below have to be specified.

| Parameters | Explanation |
|:-----------|:------------|
| add_disk |   When you run this role for the first time, disk should be added to the cluster, so "add_disk" should be "yes". When you run after that, disk should not be added anymore, so "add_disk" should be "no" |

Also, roles/core_centos7/files/disks have to be specified following your env

```
/dev/sdb
/dev/sdc
/dev/sdd
```


## Examples

### case4

```
$ ansible-playbook -i hosts_case4 site.yml --extra-vars '{
 "db":"mariadb",
 "use_hosts":"yes",
 "clush_nodes":"ovirt0 ovirt1 ovirt2",
 "add_disk":"yes",
 "mapr_version":"5.2.0",
 "mep_version":"2.0",
 "cldb_nodes":"ovirt0,ovirt1",
 "zookeeper_nodes":"ovirt0:5181",
  "cluster_name":"sample",
"mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
"hive_password":"hive",
"hivemeta":"ovirt2"
}'
```

