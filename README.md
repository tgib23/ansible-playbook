# ansible for linux dev

## setup process for centos7

For process centos7, specifying the parameters below is necessary.
* mapruser_password
* cldb_nodes
* zookeeper_nodes
* cluster_name

1. enable login to each host by "root" user without any password
2. fix hosts of [centos7]
2. fix roles/mapr_server/files/disks for your env
3. execute ansible with extra vars
```
ansible-playbook -i hosts site.yml --limit centos7 --extra-vars '{ "mapr_version":"5.2.0", "cldb_nodes":"node0,node1,node2", "zookeeper_nodes":"node0:5181,node1:5181,node2:5181", "cluster_name":"sample", "mapruser_password":"ENCRYPTED_PASSWORD"}'
```
4. set the license


## hivemeta

```
ansible-playbook -i hosts site.yml --limit hivemeta --extra-vars '{ "diskadd":"no", "mapr_version":"5.2.0", "cldb_nodes":"ovirt0,ovirt1,ovirt2", "zookeeper_nodes":"ovirt0:5181,ovirt1:5181,ovirt2:5181", "cluster_name":"sample", "mapruser_password":"$6$0FsX6QWhxP5yHf0.$ceGG6Crjyjnwc9MHsgvPEakdNS.Q76VvDFb4k2l6KGNYjdGzFTG5yxq6bPUsBBuhpw/i.e50aeH1.RYJDGKaJ0", "hive_password":"hive", "hivemeta":"ovirt2"}'
```
