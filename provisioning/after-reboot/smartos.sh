if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo "Usage: $0 <environment (production, performance)> <hostname> <puppetmaster internal ip>"
  exit
fi

SCRIPT_ENVIRONMENT=$1
SCRIPT_HOST=$2
SCRIPT_PUPPET_INTERNAL_IP=$3

PUPPET_VERSION="3.1.1"

sudo sed -i "$ a\
$SCRIPT_PUPPET_INTERNAL_IP puppet" /etc/hosts

sudo pkgin -y install ruby18-rubygems ruby18-facter ruby18-base
sudo gem18 install puppet --version "$PUPPET_VERSION"

sudo mkdir /var/lib
sudo mkdir /etc/puppet

svccfg import /opt/local/lib/ruby/gems/1.8/gems/puppet-$PUPPET_VERSION/ext/solaris/smf/puppetd.xml
svcadm disable puppetd

sudo bash -c "echo -e [main]\\npluginsync=true\\n[agent]\\nreport=true\\nenvironment=$SCRIPT_ENVIRONMENT > /etc/puppet/puppet.conf"
sudo puppet agent --test

echo "Setup complete and cert requested. Sign the cert on the puppet master using 'puppet cert sign', then come back to this machine and run 'sudo puppet agent -t' to apply the puppet config"
