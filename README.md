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
ansible-playbook -i hosts site.yml --limit centos7 --extra-vars '{ "cldb_nodes":"node0,node1,node2", "zookeeper_nodes":"node0:5181,node1:5181,node2:5181", "cluster_name":"sample", "mapruser_password":"ENCRYPTED_PASSWORD"}'
```
4. set the license
