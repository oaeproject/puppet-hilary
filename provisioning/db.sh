#!/bin/sh

# CentOS

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

yum --enablerepo="puppetlabs,puppetlabsdeps" install -y puppet
yum --enablerepo="epel" install -y git

git clone http://github.com/mrvisser/puppet-hilary
cd puppet-hilary
echo "performance" > .environment