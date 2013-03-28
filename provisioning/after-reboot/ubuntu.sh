if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo "Usage: $0 <environment (production, performance)> <hostname> <puppetmaster internal ip>"
  exit
fi

SCRIPT_ENVIRONMENT=$1
SCRIPT_HOSTNAME=$2
SCRIPT_PUPPET_INTERNAL_IP=$3

mkdir /var/lib/apt/lists/
apt-get update

# First include the puppet apt repo
cd /tmp
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
apt-get update

# install 3.1.1
apt-get -y install puppet=3.1.1-1puppetlabs1

# Now install puppet

cat > /etc/puppet/puppet.conf <<EOF
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates
prerun_command=/etc/puppet/etckeeper-commit-pre
postrun_command=/etc/puppet/etckeeper-commit-post
pluginsync=true

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY

[agent]
report=true
environment=$SCRIPT_ENVIRONMENT
EOF

cat > /etc/default/puppet <<EOF
# Defaults for puppet - sourced by /etc/init.d/puppet

# Start puppet on boot?
START=yes

# Startup options
DAEMON_OPTS=""
EOF

puppet agent --test

echo "Setup complete and cert requested. Sign the cert on the puppet master using 'puppet cert sign', then come back to this machine and run 'sudo puppet agent -t' to apply the puppet config"