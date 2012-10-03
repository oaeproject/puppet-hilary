#!/usr/bin/sh

cd ~
sudo pkgin -y install ruby19-puppet
sudo pkgin -y install scmgit
git clone http://www.github.com/mrvisser/puppet-hilary
cd puppet-hilary
echo "performance" > .environment
