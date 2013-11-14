#!/usr/bin/env bash

cd /vagrant

# Do a basic check to see if we have a good environment to start from
# Check if the oracle-java binary is present
ORACLE_JDK_INSTALLER="jdk-6u45-linux-x64.bin"
if [ ! -f /vagrant/modules/oracle-java/files/$ORACLE_JDK_INSTALLER ] ; then
    echo "The Oracle JDK installer is not present in the correct location or is not executable."
    echo "Please download $ORACLE_JDK_INSTALLER from the Oracle website and place it at:"
    echo "modules/oracle-java/files/$ORACLE_JDK_INSTALLER"
    exit 1
fi

# Check if the installer is marked as executable
if [ ! -x /vagrant/modules/oracle-java/files/$ORACLE_JDK_INSTALLER ] ; then
    echo "The Oracle JDK installer was not marked as executable, marking it for you."
    chmod 755 /vagrant/modules/oracle-java/files/$ORACLE_JDK_INSTALLER
fi

# We need puppet version 3.3.1
PUPPET_VERSION=$(puppet help | tail -n 1 | cut -f 2 -d " ")
if [ "${PUPPET_VERSION}" != "v3.3.1" ] ; then
    echo "Puppet was on version ${PUPPET_VERSION} but should be on version 3.3.1. Updating."

    echo "Installing puppetlabs repo"
    cd /tmp
    wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
    dpkg -i puppetlabs-release-precise.deb
    apt-get update

    echo "Updating puppet"
    apt-get -y install puppet=3.3.1-1puppetlabs1
fi

# We need puppet/apt
if [ ! -d /home/vagrant/.puppet ] || [ ! -d /home/vagrant/.puppet/modules ] || [ ! -d /home/vagrant/.puppet/modules/apt ]; then
    puppet module install puppetlabs/apt
fi

# We need curl
which curl
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Installing curl"
    apt-get -y install curl
fi

# We need git
which git
STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Install git"
    apt-get -y install git
fi

# Enable  multiverse repositories
echo "Enable multiverse repositories"
sudo sed -i "/^# deb.*multiverse/ s/^# //" /etc/apt/sources.list
sudo apt-get update

# Make sure all the submodules have been pulled down
cd /vagrant
sh bin/pull.sh

# Run puppet
echo "Applying puppet catalog. This might take a while (~30+ mins is not unreasonable)"
puppet apply --verbose --debug --modulepath environments/local/modules:modules:/etc/puppet/modules --certname dev --environment local --hiera_config provisioning/vagrant/hiera.yaml site.pp

STATUS_CODE=$?
if [ $STATUS_CODE -ne 0 ] ; then
    echo "Got a ${STATUS_CODE} status code, which indicates the puppet catalog could not be properly applied."
    echo "There are a couple of possible things you can do:"
    echo " - Run vagrant ssh and try running cd /vagrant && puppet apply --verbose --debug --modulepath environments/local/modules:modules:/etc/puppet/modules --certname dev --environment local --hiera_config provisioning/vagrant/hiera.yaml site.pp"
    echo " - If you're familiar with puppet try to analyze the output and tweak the puppet scripts"
    echo " - Hop onto #sakai on irc.freenode.org and ask if anyone has seen your error"
    echo " - Shoot an e-mail to oae-dev@sakaiproject.org with the above output"
    echo "Since puppet didn't finish properly, we have to abort here"
    exit 1;
fi

# Bounce all the services just in case.
echo "The puppet catalog has been applied. We're now bouncing all the services to get everything up and running."
service cassandra restart
service elasticsearch restart
service rabbitmq-server restart
service redis-server restart
service hilary restart
service nginx restart

echo "Sleeping 15 seconds to give the app server a little bit of time to start up"
sleep 15

curl http://localhost:2000/api/me

echo "Everything has been installed."
echo "Make sure you have the following entries in your host machine's /etc/hosts file:"
echo "     127.0.0.1 admin.vagrant.oae"
echo "     127.0.0.1 tenant1.vagrant.oae"
echo "     127.0.0.1 tenant2.vagrant.oae"
echo "     127.0.0.1 tenant3.vagrant.oae"
echo "You should be able to browse to http://admin.vagrant.oae:8123 on your host machine and set up a new tenant. You can use tenant1.vagrant.oae:8123, tenant2.vagrant.oae:8123 or tenant3.vagrant.oae:8123 as the hostname when creating a new tenant in the admin UI."
echo "Enjoy!"
