#!/bin/sh

# CentOS 5

cat > /etc/yum.repos.d/puppet.repo <<EOF
[puppetlabs]
name=Puppet Labs Packages
baseurl=http://yum.puppetlabs.com/el/\$releasever/products/\$basearch
enabled=0
gpgcheck=0
EOF

cat > /etc/yum.repos.d/epel.repo <<EOF
[epel]
name=Extra Packages for Enterprise Linux 5 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/5/\$basearch
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=\$basearch
failovermethod=priority
enabled=0
gpgcheck=0

[epel-puppet]
name=epel puppet
baseurl=http://tmz.fedorapeople.org/repo/puppet/epel/5/\$basearch/
enabled=0
gpgcheck=0
EOF

yum install -y ruby
yum --enablerepo="epel,epel-puppet" install -y puppet
yum --enablerepo="epel" install -y git

git clone http://github.com/mrvisser/puppet-hilary
cd puppet-hilary