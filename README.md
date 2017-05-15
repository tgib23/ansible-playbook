# ansible for MapR cluster setup

This playbook is for creating MapR cluster.
I hope this will be another re-invention of mapr-installer.

## Motivation

[mapr-installer](http://maprdocs.mapr.com/home/MapRInstaller.html) is a great tool to build up a MapR cluster, but there are some restrictions such as
* no multiple master roles for HA
* no client setup

It is possible to build multiple master roles and client with this ansible script.

## Verification

| OS | MapR Version | MEP |
|:---|:------------|:-----|
|CentOS 6, CentOS 7 | 5.2.0, 5.2.1 | 3.0 |

## Requirement

* Each node has the same disk setup for MFS
    * if one node uses /dev/sdb,/dev/sdc,/dev/sdd then, other nodes also use the same disk path for MFS
* Look at the [issues](https://github.com/tgib23/ansible-playbook-mapr/issues)

## Preparation

### Setup for Cluster Nodes and ansible Client Node

* install ansible-playbook on ansible client node
* hostname has to be setup manually on cluster nodes (or setup DNS) for solving hostname
    * If you are using CentOS 6, you should edit /etc/sysconfig/network
    * If you are using CentOS 7, you should edit /etc/hostname
* enable ssh login to each node by root user without password from ansible client node

### Configuration for ansible
* prepare 'hosts' file in the root directory using hosts_case or example files
* edit roles/common/files/hosts, which will be copied to /etc/hosts of your cluster nodes, in case you use /etc/hosts to solve IP-Hostname of other nodes
* edit roles/rerun_warden/files/disks to specify the disk path for MFS on cluster nodes. Only this file is used in every cluster node, so that the disk path of each node has to be identical.

## parameter

| Parameters | Explanation | role | Mandatory |
|:-----------|:------------|:------|:---------|
| os | cent6 or cent7 | common | Y |
| use_hosts | If you use /etc/hosts to resolve IP-Hostname of your cluster, you should write those relations in roles/common/files/hosts, and then, use "use_hosts" parameter and say "yes". | common | N |
| mapr_version | mapr version to install. Ex. '5.2.0' | common | Y |
| mep_version | mep version to install. Ex. '2.0' | common, hue, spark-master, tez | Y |
| clush_nodes |   space separated nodes list to setup clustershell | common | Y |
| oozie | oozie server host | common | N |
| hive_password | password for user "hive" for mysqldb/mariadb. | mysql | Y |
| hue_password | password for user "hue" for mysqldb/mariadb.   | mysql | Y |
| zookeeper_nodes | zookeeper nodes for dynamic service discovery. csv style | hive, hivemeta, config, hiveserver2, tez, posix-client-basic  | Y |
| hivemeta | node to install hivemeta | hive, hivemeta, mysql, tez | Y |
| db | "mysqldb" or "mariadb". default db of centos6 is mysqldb and centos7 is mariadb |
| httpfs | httpfs_server host | hue | Y |
| resource_manager | resource_manager host | hue | Y |
| hiveserver | hiveserver host | hue | Y |
| historyserver |   historyserver host | hue, config | Y |
| impala_statestore | impala state store host | impala | Y |
| impala_catalog | impala catalog host | impala | Y |
| cldb_nodes | comma separated list of cldb nodes. Ex "node0,node1,node2" | config, posix-client-basic | Y |
| cluster_name |   cluster name | config | Y |
| add_disk |   When you run this role for the first time, disk should be added to the cluster, so "add_disk" should be "yes". When you run after that, disk should not be added anymore, so "add_disk" should be "no" | rerun_warden | Y |

## Notes for roles

### hiveserver2

hiveserver2 role installs hiveserver2 and setup configuration.
This role configures hiveserver to [enable impersonation](http://maprdocs.mapr.com/home/Hive/HiveUserImpersonation-Enable.html)
Parameters below have to be specified.

### hue

assumption
* configured to run httpfs, resourcemanager, hive
* assuming hive 2.1

### spark

In case using Spark on Yarn, just use \[spark\] and \[spark-historyserver\].
In case using Spark Standalone, use \[spark-master\], \[spark\] for spark slave, and \[spark-historyserver\].

### drill-yarn

Install drill on yarn.
Configurations for eachstorage is necessary after installing.

```
$ /opt/mapr/drill/drill-1.10.0/bin/drill-on-yarn.sh --site /opt/mapr/drill/site start 
pplication ID: application_1492660206907_0003
Application State: RUNNING
Host: cent64/10.10.75.117
Queue: root.mapr
User: mapr
Start Time: 2017-04-20 03:31:08
Application Name: Drill-on-YARN
Tracking URL: http://cent63:8088/proxy/application_1492660206907_0003/
AM State: LIVE
Target Drillbit Count: 1
Live Drillbit Count: 1
Unmanaged Drillbit Count: 0
Blacklisted Node Count: 1
Free Node Count: 3
For more information, visit: http://10.10.75.117:8048/
```
Access Drillbit Application Master above.

## Examples

### case1

* install MapR 5.2.0 on centos6
* zookeeper, cldb, webserver, nfsserver, hivemeta, hiveserver are installed on (not the same) single node
* hive uses mysqldb
* fileserver and nodemanager are redundant
* use hosts_case1

```
$ ansible-playbook -i hosts_case1 cluster.yml -u root -k --extra-vars '{
  "os":"cent6",
  "db":"mysqldb",
  "use_hosts":"yes",
  "clush_nodes":"cent61 cent62 cent63",
  "add_disk":"yes",
  "mapr_version":"5.2.0",
  "mep_version":"2.0",
  "cldb_nodes":"cent62",
  "zookeeper_nodes":"cent61:5181",
  "cluster_name":"cent6",
  "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
  "hivemeta":"cent63",
  "hive_password":"hive"
}'
```

### case2

* install MapR 5.2.0 on centos6
* zookeeper, cldb, webserver, nfsserver, hivemeta, hiveserver, historyserver, spark-historyserver are installed on (not the same) single node
* hive uses mysqldb
* fileserver and nodemanager are redundant
* use hosts_case2

```
ansible-playbook -i hosts_case2 cluster.yml -u root -k --extra-vars '{
  "os":"cent6",
 "db":"mysqldb",
 "use_hosts":"yes",
 "clush_nodes":"cent61 cent62 cent63",
 "add_disk":"yes",
 "mapr_version":"5.2.0",
 "mep_version":"2.0",
 "cldb_nodes":"cent62",
 "zookeeper_nodes":"cent61:5181",
 "cluster_name":"cent6",
 "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
 "hivemeta":"cent63",
 "hive_password":"hive",
 "resource_manager":"cent62",
 "historyserver":"cent63"}'
```

### case3

* install MapR 5.2.0 on centos6
* HA for zookeeper and cldb
* nfsserver on node2, and loopbacknfs on node3

```
$ ansible-playbook -i hosts_case3 cluster.yml -u root -k --extra-vars '{
 "os":"cent6",
 "db":"mysqldb",
 "use_hosts":"yes",
 "clush_nodes":"ecent61 ecent62 ecent63",
 "add_disk":"yes",
 "mapr_version":"5.2.0",
 "mep_version":"2.0",
 "cldb_nodes":"ecent61,ecent62,ecent63",
 "zookeeper_nodes":"ecent61:5181,ecent62:5181,ecent63:5181",
 "cluster_name":"ecent6",
 "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
 "hivemeta":"ecent62",
 "hive_password":"hive",
 "resource_manager":"ecent63",
 "historyserver":"ecent63"
}'
```

### case4

```
$ ansible-playbook -i hosts_case4 cluster.yml --extra-vars '{
 "os":"cent7",
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

### case5

* Install MapR 5.2.0 community edition on Centos7
* cldb, zookeeper is installed as master node

```
$ ansible-playbook -i hosts_case5 cluster.yml -u root -k --extra-vars '{
 "os":"cent7",
 "db":"mariadb",
 "use_hosts":"yes",
 "clush_nodes":"cent71 cent72 cent73",
 "add_disk":"yes",
 "mapr_version":"5.2.0",
 "mep_version":"2.0",
 "cldb_nodes":"cent71",
 "zookeeper_nodes":"cent71:5181",
 "cluster_name":"cent7",
 "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
}'
```

### case6
* Install MapR 5.2.0 community edition on Centos7
* Install hue and httpfs

```
ansible-playbook -i hosts_case6 cluster.yml -u root -k --extra-vars '{
  "os":"cent7",
  "db":"mysqldb",
  "use_hosts":"no",
  "clush_nodes":"ecent61 ecent62 ecent63",
  "add_disk":"yes",
  "mapr_version":"5.2.1",
  "mep_version":"3.0",
  "cldb_nodes":"ecent62,ecent63",
  "zookeeper_nodes":"ecent61:5181,ecent62:5181,ecent63:5181",
  "cluster_name":"ecent6",
  "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
  "hivemeta":"ecent62",
  "hive_password":"hive",
  "resource_manager":"ecent63",
  "httpfs":"ecent61",
  "hiveserver":"ecent62",
  "historyserver":"ecent63"}'
```

### case 7

* Install MapR 5.2.1 with MEP 3.0
* deploy with 5 nodes cluster
* use spyglass

```
ansible-playbook -i hosts_case7 cluster.yml -u root -k --extra-vars '{
  "os":"cent6",
  "db":"mysqldb",
  "use_hosts":"yes",
  "clush_nodes":"cent61 cent62 cent63 cent64 cent65",
  "add_disk":"yes",
  "mapr_version":"5.2.1",
  "mep_version":"3.0",
  "cldb_nodes":"cent62,cent63",
  "zookeeper_nodes":"cent61:5181,cent62:5181,cent63:5181",
  "cluster_name":"cent6",
  "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
  "hivemeta":"cent62",
  "hive_password":"hive",
  "resource_manager":"cent63",
  "httpfs":"cent63",
  "hiveserver":"cent62",
  "historyserver":"cent63",
  "elastic_search":"cent64,cent65",
  "opentsdb":"cent64"
}'
```

### POSIX client case

* install posix fuse basic client

```
ansible-playbook -i hosts_client_case_1 client.yml -u root -k --extra-vars '{
 "use_hosts":"yes",
 "mapr_version":"5.2.0",
 "mep_version":"2.0",
 "cldb_nodes":"syamada-dist2,syamada-dist0",
 "zookeeper_nodes":"syamada-dist0:5181,syamada-dist2:5181,syamada-dist3:5181",
 "cluster_name":"syamada52",
 "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0",
}'
```
