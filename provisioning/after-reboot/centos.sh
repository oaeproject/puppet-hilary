if [ "$1" = "" -o "$2" = "" -o "$3" = "" ]
then
  echo "Usage: $0 <environment (production, performance)> <hostname> <puppetmaster internal ip>"
  exit
fi

SCRIPT_ENVIRONMENT=$1
SCRIPT_HOSTNAME=$2
SCRIPT_PUPPET_INTERNAL_IP=$3

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
yum --enablerepo="puppetlabs,puppetlabsdeps" install -y puppet

cat > /etc/puppet/puppet.conf <<EOF
[main]
# The Puppet log directory.
# The default value is '$vardir/log'.
logdir = /var/log/puppet

# Where Puppet PID files are kept.
# The default value is '$vardir/run'.
rundir = /var/run/puppet

# Where SSL certificates are kept.
# The default value is '$confdir/ssl'.
ssldir = $vardir/ssl
pluginsync=true

[agent]
# The file in which puppetd stores a list of the classes
# associated with the retrieved configuratiion.  Can be loaded in
# the separate ``puppet`` executable using the ``--loadclasses``
# option.
# The default value is '$confdir/classes.txt'.
classfile = $vardir/classes.txt

# Where puppetd caches the local configuration.  An
# extension indicating the cache format is added automatically.
# The default value is '$confdir/localconfig'.
localconfig = $vardir/localconfig
report=true
environment=$SCRIPT_ENVIRONMENT
EOF

# MCollective
yum install -y --enablerepo=puppetlabs mcollective-2.2.3

# MCollective Plugins
yum install -y --enablerepo=puppetlabs mcollective-puppet-agent-1.5.1-1 mcollective-package-agent-4.2.0-1

cat > /etc/mcollective/server.cfg <<EOF
# main config
libdir = /usr/libexec/mcollective
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

puppet agent --test

echo "Setup complete and cert requested. Sign the cert on the puppet master using 'puppet cert sign', then come back to this machine and run 'sudo puppet agent -t' to apply the puppet config"