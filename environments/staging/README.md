# Open Academic Environment (OAE) Staging Environment

The OAE staging environment is run on a Joyent cluster. The app nodes are run on 2 SmartOS 64bit smartmachines, while the Cassandra nodes are running on 3 CentOS 6 Linux machines. There is a reverse proxy powered by Nginx, running on a 64bit SmartOS smartmachine as well.

Currently a puppet master is not installed, so doing things like terminating / recreating nodes and adding new nodes will be difficult. You will need to:

a) Update the `modules/localconfig/manifests/init.pp` configuration spec to include the information of the new node (e.g., different IP, new IP, etc...)

b) Apply the new configuration info manually to each and every node that is affected (this is the part puppet master does for you, if it's configured)

## Install an App Node

1. From the Joyent Cloud admin, create a new `base64` machine
2. After it's created, ssh into it using `ssh admin@<external ip>` . You should have a public key configured on your Joyent account that allows you to do this without a password.
3. From the admin home directory, run the following command to initialize the app machine:

`curl --insecure https://raw.github.com/oaeproject/puppet-hilary/master/provisioning/app.sh | sh`

4\. Then create a file specifying the node name of this node (as per the `modules/localconfig/manifests/nodes.pp` specs):

```
$ cd puppet-hilary
$ echo "app0" > .node
```

5\. Then pull in the submodules and apply the puppet config (**sudo is required for running apply.sh**):

```
$ bin/pull.sh
$ sudo bin/apply.sh
```

6\. Done, your app node should now be running. If you didn't have a cassandra node deployed, it probably filed while starting up. Big time.

Your app directory is located it `/opt/oae`. The process is called `node` if you need to kill it. No, there is no init script, yet.

## Install a Cassandra Node

**Warning:** There are subtle differences between these instructions and the app node instructions above. Such as logging in as **root** instead of admin, and not using **sudo**, because you're root. Please follow carefully.

1. From the Joyent Cloud admin, create a new `centos 6` machine
2. After it's created, ssh into it using `ssh root@<external ip>` . You should have a public key configured on your Joyent account that allows you to do this without a password.
3. From the admin home directory, run the following command to initialize the db machine:

**Note: The file is db.sh, not app.sh**

`curl --insecure https://raw.github.com/oaeproject/puppet-hilary/master/provisioning/db.sh | sh`

4\. Then create a file specifying the node name of this node (as per the `modules/localconfig/manifests/nodes.pp` specs):

```
$ cd puppet-hilary
$ echo "db0" > .node
```

5\. Then pull in the submodules and apply the puppet config:

```
$ bin/pull.sh
$ bin/apply.sh
```

6\. Done, your cassandra node should now be running. If you installed the node that has Datastax OpsCenter, then it will be accessible at port 8888 on the external IP of the node.
