# Open Academic Environment (OAE Project)

Puppet configuration and environment management for the [Open Academic Environment](http://www.oaeproject.org/)

## Environments

### Local machine / Vagrant

It's possible to get OAE up and running on your local machine using [Vagrant(http://www.vagrantup.com)] by following these steps:

#### Preparation

##### Install VirtualBox and Vagrant

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* Install [Vagrant](http://downloads.vagrantup.com)

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

Dependencies such as Cassandra and Elasticsearch perform best on the Oracle JDK 6. Unfortunately, we cannot automate the step that downloads the JDK itself
as you need to accept the Oracle Binary Code License Agreement.
You can download the JDK (jdk-6u45-linux-x64.bin) on [Oracle's JDK6 download page](http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase6-419409.html#jdk-6u45-oth-JPR).
You should save it at `~/OAE/puppet-hilary/modules/oracle-java/files/jdk-6u45-linux-x64.bin`.

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


### AWS/Vagrant 

Follow [Vagrant-AWS instruction](https://github.com/mitchellh/vagrant-aws) to setup vagrant for aws. Make sure that ssh is allowed default security group

Modify `puppet-hilary/Vagrantfile` according to the example below. 
Note that this example use Ubuntu 12.04 ami and a medium instance

```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Use the “dummy” box to host
  config.vm.box = "dummy"

  # Share the backend and front-end code with vagrant.
  # It's assumed that Hilary and 3akai-ux are on the same level as puppet-hilary.
  # Note that puppet will change some files in these directories
  config.vm.synced_folder "../Hilary", "/opt/oae"
  config.vm.synced_folder "../3akai-ux", "/opt/3akai-ux"

  # Run a shell script that will do some basic bootstrapping and finally runs puppet.
  config.vm.provision :shell, :path => "provisioning/vagrant/init.sh"

  # configure aws
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "your access key id"
    aws.secret_access_key = "your secret access key"
    aws.keypair_name = "your keypair name"

    aws.ami = "ami-7747d01e"
    aws.instance_type = "m1.medium"
    aws.tags = {
      'Name' => 'oae-demo'
    }

    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "full path to your private key"
  end

end
```

Change web domain in `puppet-hilary/environments/local/hiera/common.json` to match your domain names

Change host names in `puppet-hilary/environments/local/modules/localconfig/manifests/hostnames.pp` to match your domain names

Add the following to `puppet-hilary/provisioning/vagrant/init.sh` 

```
# enable  multiverse repositories
echo "enable multiverse repositories"
sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
sudo apt-get update
```
Restart server (`sudo reboot`) and assocate a fix IP to the new instance if necessary

Run `vagrant ssh`, and go to `/opt/oae` folder and run `sudo service hilary restart`, then wait for a few minutes, your OAE demo using aws should be ready!



