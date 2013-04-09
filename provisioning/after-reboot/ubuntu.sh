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

# install puppet 3.1.1
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

# MCollective server (i.e., on each of the cluster nodes)
apt-get -y install mcollective=2.2.3-1
gem install stomp

# Agent plugins
apt-get -y install mcollective-puppet-agent=1.5.1-1 mcollective-package-agent=4.2.0-1

# MCollective config
cat > /etc/mcollective/server.cfg <<EOF
# main config
libdir = /usr/share/mcollective/plugins
logfile = /var/log/mcollective.log
daemonize = 1
keeplogs = 0
max_log_size = 10240
loglevel = debug
identity = $SCRIPT_HOSTNAME
registerinterval = 300

# connector plugin config
connector = activemq
plugin.activemq.pool.size = 1
plugin.activemq.pool.1.host = puppet
plugin.activemq.pool.1.port = 61613
plugin.activemq.pool.1.user = mcollective
plugin.activemq.pool.1.password = marionette

# facts
factsource = yaml
plugin.yaml = /etc/mcollective/facts.yaml

# security plugin config
securityprovider = psk
plugin.psk = abcdefghj
EOF

service mcollective restart

echo "Setup complete."