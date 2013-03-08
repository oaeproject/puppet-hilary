#!/bin/sh

# Ubuntu

####################################################################################
#
# Ubuntu Joyent Performance testing environment setup.
#
# DON'T RUN THIS ON A PRODUCTION MACHINE. This is not
# safe for production!
#
####################################################################################

echo "Backing /etc/hosts to /etc/hosts.bck. This will be modified to include the Joyent machine ID"
cp /etc/hosts /etc/hosts.bck
cat > /etc/hosts <<EOF
127.0.0.1   localhost.localdomain localhost $HOSTNAME
::1         localhost.localdomain localhost $HOSTNAME
EOF

echo "Setting up apt repositories"
apt-get -y install python-software-properties python g++ make
add-apt-repository -y ppa:chris-lea/node.js
apt-get update

echo "Installing bootstrap dependencies"
apt-get -y install git-core
apt-get -y install puppet

echo "Setting up puppet scripts"
git clone http://github.com/sakaiproject/puppet-hilary
cd puppet-hilary
echo "performance" > .environment
