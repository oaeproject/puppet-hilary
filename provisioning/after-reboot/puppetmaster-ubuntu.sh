
# Open up the devel repos
sed -i 's/# deb /deb /g' /etc/apt/sources.list.d/puppetlabs.list
apt-get update

# Install the puppetlabs repos
cd /tmp
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb

# Install git and puppetmaster
apt-get install -y git puppetmaster-passenger

# Configure PuppetMaster
cat > /etc/puppet/puppet.conf <<EOF
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=\$vardir/lib/facter
templatedir=\$confdir/templates
pluginsync=true

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN 
ssl_client_verify_header = SSL_CLIENT_VERIFY

# Use puppet-hilary checkout
modulepath = \$confdir/puppet-hilary/environments/\$environment/modules:\$confdir/puppet-hilary/modules:\$confdir/modules
manifest = \$confdir/puppet-hilary/site.pp
reports = store, http
reporturl = http://puppet/reports/upload
EOF

cat > /etc/puppet/hiera.yaml <<EOF
:backends:
  - json
:json:
  :datadir: /etc/puppet/puppet-hilary/environments/%{::environment}/hiera
:hierarchy:
  - %{::clientcert}_hiera_secure
  - %{::clientcert}
  - %{nodetype}_hiera_secure
  - %{nodetype}
  - common_hiera_secure
  - common
EOF

git clone git://github.com/sakaiproject/puppet-hilary /etc/puppet/puppet-hilary
cd /etc/puppet/puppet-hilary
git fetch origin
git checkout production
bin/pull.sh

## Puppet Dashboard

# Set root password to "root" for the upcoming mysql prompt
echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

apt-get install -y build-essential irb libmysql-ruby libmysqlclient-dev libopenssl-ruby libreadline-ruby mysql-server rake rdoc ri ruby ruby-dev

# Install rubygems (do not use the installation that came w/ OS)
URL="http://production.cf.rubygems.org/rubygems/rubygems-1.3.7.tgz"
PACKAGE=$(echo $URL | sed "s/\.[^\.]*$//; s/^.*\///")

cd $(mktemp -d /tmp/install_rubygems.XXXXXXXXXX) && \
wget -c -t10 -T20 -q $URL && \
tar xfz $PACKAGE.tgz && \
cd $PACKAGE && \
ruby setup.rb

update-alternatives --install /usr/bin/gem gem /usr/bin/gem1.8 1
apt-get install -y puppet-dashboard

# Create 'dashboard' user with password 'dashboard'
mysql -u root -proot -e "CREATE DATABASE dashboard CHARACTER SET utf8;"
mysql -u root -proot -e "CREATE USER 'dashboard'@'localhost' IDENTIFIED BY 'dashboard';"
mysql -u root -proot -e "GRANT ALL PRIVILEGES ON dashboard.* TO 'dashboard'@'localhost';"

cat > /usr/share/puppet-dashboard/config/database.yml <<EOF
production:
    database: dashboard
    username: dashboard
    password: dashboard
    encoding: utf8
    adapter: mysql
EOF
chmod 660 /usr/share/puppet-dashboard/config/database.yml

# Deploy the database
cd /usr/share/puppet-dashboard
sed -i 's/max_allowed_packet.*/max_allowed_packet = 32M/g' /etc/mysql/my.cnf
service mysql restart
rake RAILS_ENV=production db:migrate

# Set up the apache configs for puppetmaster and dashboard
rm -f /etc/apache2/sites-enabled/*
cat > /etc/apache2/sites-enabled/000-puppetmaster <<EOF
PassengerHighPerformance on
PassengerMaxPoolSize 12
PassengerPoolIdleTime 1500
# PassengerMaxRequests 1000
PassengerStatThrottleRate 120
RackAutoDetect Off
RailsAutoDetect On

Listen 8140

<VirtualHost *:8140>
SSLEngine on
SSLProtocol -ALL +SSLv3 +TLSv1
SSLCipherSuite ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP

SSLCertificateFile      /var/lib/puppet/ssl/certs/puppet.pem
SSLCertificateKeyFile   /var/lib/puppet/ssl/private_keys/puppet.pem
SSLCertificateChainFile /var/lib/puppet/ssl/certs/ca.pem
SSLCACertificateFile    /var/lib/puppet/ssl/certs/ca.pem
# If Apache complains about invalid signatures on the CRL, you can try disabling
# CRL checking by commenting the next line, but this is not recommended.
SSLCARevocationFile     /var/lib/puppet/ssl/ca/ca_crl.pem
SSLVerifyClient optional
SSLVerifyDepth  1
SSLOptions +StdEnvVars

RequestHeader set X-SSL-Subject %{SSL_CLIENT_S_DN}e
RequestHeader set X-Client-DN %{SSL_CLIENT_S_DN}e
RequestHeader set X-Client-Verify %{SSL_CLIENT_VERIFY}e

DocumentRoot /usr/share/puppet/rack/puppetmasterd/public/
RackBaseURI /
<Directory /usr/share/puppet/rack/puppetmasterd/>
Options None
AllowOverride None
Order allow,deny
allow from all
</Directory>
</VirtualHost>
EOF

cat > /etc/apache2/sites-enabled/010-dashboard <<EOF
<VirtualHost *:80>
DocumentRoot /usr/share/puppet-dashboard/public/
<Directory /usr/share/puppet-dashboard/public/>
    Options None
    Order allow,deny
    allow from all
</Directory>
ErrorLog /var/log/apache2/dashboard.error.log
LogLevel warn
CustomLog /var/log/apache2/dashboard.access.log combined
ServerSignature On
</VirtualHost>
EOF

service apache2 restart

# Enable the dashboard workers
sed -i 's/### START=no/START=yes/g' /etc/default/puppet-dashboard-workers
touch /usr/share/puppet-dashboard/log/production.log
chmod 0666 /usr/share/puppet-dashboard/log/production.log
service puppet-dashboard-workers start

echo "Puppet master setup complete. Hilary puppet config is found in /etc/puppet/puppet-hilary"
