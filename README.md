# Open Academic Environment (OAE Project)

Puppet configuration and environment management for the [Open Academic Environment](http://www.oaeproject.org/)

## Environments

### Local machine / Vagrant

It's possible to get OAE up and running on your local machine using [Vagrant(http://www.vagrantup.com)] by following these steps:

#### Preparation

##### Install VirtualBox and Vagrant

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](http://downloads.vagrantup.com) - You'll need at least version 1.6

##### Get the source code

Clone [Hilary](https://github.com/oaeproject/Hilary), [3akai-ux](https://github.com/oaeproject/3akai-ux) and [puppet-hilary](https://github.com/oaeproject/puppet-hilary) and make sure they are all in the same folder. You should have something like:

```
+ OAE
|-- + 3akai-ux
|-- + Hilary
|-- + puppet-hilary
```

You should **NOT** attempt to use these directories straight from your host OS as they will contain linux specific compiled binaries and will not work on your host OS.
Vice versa, do not try to share anything that you compiled on your host OS with Vagrant.

##### Download the Oracle JDK

Dependencies such as Cassandra and Elasticsearch perform best on Oracle JDK 7. Unfortunately, we cannot automate the step that downloads the JDK itself as you need to accept the Oracle Binary Code License Agreement.
You can download the JDK (jdk-7u65-linux-x64.tar.gz) on [Oracle's JDK7 download page](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html#jdk-7u65-oth-JPR).
You should save it at `~/OAE/puppet-hilary/modules/oracle-java/files/jdk-7u65-linux-x64.gz`. (Note that Oracle lists the file incorrectly as `.tar.gz` whilst it is actually `.gz`)

##### Configure your hosts file

The hosts file is a file that allows you to map fake domain names to certain IP addresses. By mapping them to
the local loopback address we can fake multiple tenants running on one system.
Edit your hosts file (`/etc/hosts` on UNIX, C:\Windows\System32\drivers\etc\hosts on Windows) and add the following entries.

```
127.0.0.1   admin.vagrant.oae
127.0.0.1   tenant1.vagrant.oae
127.0.0.1   tenant2.vagrant.oae
127.0.0.1   tenant3.vagrant.oae
```

##### Configure the amount of memory Vagrant/VirtualBox can use.

By default the VM will be allotted 3072MB of RAM. If you do not have this much RAM available,
you can change this in the VagrantFile found in OAE/puppet-hilary.

#### Getting up and running

cd into the `puppet-hilary` directory and run:

```
vagrant box add oae http://files.vagrantup.com/precise64.box
vagrant up
```

This command will pull down a VirtualBox image and deploy all the necessary components onto it.
Depending on how fast your host machine and internet connection is, this can take quite a while. Initial set-ups of 30-45 minutes are not uncommon.


Once that is done you should have a VM with a fully functioning environment.
Open your browser and go to http://admin.vagrant.oae:8123 and you should be presented with the Admin UI.

#### Notes

 * The app server logs can be found at /opt/oae/server.log (or at OAE/Hilary/server.log on your host machine).
 * If you make changes to the backend code you will need to restart the app server. This can be done by ssh'ing into the client machine by running `vagrant ssh` and running `service Hilary restart`.
 * Even if you'd install all the components on your host OS, you would not be able to run the server as some of the npm modules are compiled during the provisioning step.
 * If you've finished your development tasks or want to free up some resources for something else, you can run `vagrant halt` which will shutdown the VM.
 * If you restart the VM using 'vagrant up', you may need to start Hilary server manually by running 'vagrant ssh' and 'sudo service hilary start'.

### Performance

Manages a fully scaled-out environment and is capable of deploying the latest code (or code that is in PR).
Is used for regular performance tests.

### Staging

Our staging environment which tries to mimic production as close as possible.

### Production

Our production environment. Fully scaled-out for redundancy rather than performance.

### QA

Contains the configuration for the QA / Release / Unit test servers.
