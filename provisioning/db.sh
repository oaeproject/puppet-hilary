#!/bin/sh

# CentOS

echo "Backing /etc/hosts to /etc/hosts.bck. This will be modified to include the Joyent machine ID"
cp /etc/hosts /etc/hosts.bck
cat > /etc/hosts <<EOF
127.0.0.1   localhost.localdomain localhost $HOSTNAME
::1         localhost.localdomain localhost $HOSTNAME
EOF

echo "Setting up yum repos"
cat > /etc/yum.repos.d/puppet.repo <<EOF
[puppetlabs]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/el/\$releasever/products/\$basearch
enabled=0
gpgcheck=0

[puppetlabsdeps]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/el/\$releasever/dependencies/\$basearch
gpgcheck=0
enabled=1
EOF

cat > /etc/yum.repos.d/epel.repo <<EOF
[epel]
name=Extra Packages for Enterprise Linux \$releasever - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/\$releasever/\$basearch
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-\$releasever&arch=\$basearch
failovermethod=priority
enabled=0
gpgcheck=0
EOF

echo "Installing bootstrap dependencies"
yum --enablerepo="puppetlabs,puppetlabsdeps" install -y puppet
yum --enablerepo="epel" install -y git

echo "Setting up puppet scripts"
git clone http://github.com/mrvisser/puppet-hilary
cd puppet-hilary
echo "performance" > .environment
