# Install git
apt-get install -y git

# Install the puppetlabs repos
cd /tmp
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb

# Open up the devel repos
sed -i 's/# deb /deb /g' /etc/apt/sources.list.d/puppetlabs.list
apt-get update
apt-get install -y puppetmaster-passenger

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

git clone git://github.com/sakaiproject/puppet-hilary /etc/puppet/puppet-hilary
cd /etc/puppet/puppet-hilary
git fetch origin
git checkout production

## Puppet Dashboard

# Run this command alone, configure MySQL when prompted
apt-get install -y build-essential irb libmysql-ruby libmysqlclient-dev \
libopenssl-ruby libreadline-ruby mysql-server rake rdoc ri ruby ruby-dev

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

# Create a 'dashboard' database in MySQL
#   mysql -u root -p
#   > CREATE DATABASE dashboard CHARACTER SET utf8;
#   > CREATE USER 'dashboard'@'localhost' IDENTIFIED BY 'my_password';
#   > GRANT ALL PRIVILEGES ON dashboard.* TO 'dashboard'@'localhost';

cat > /usr/share/puppet-dashboard/config/database.yml <<EOF
production:
database: dashboard
username: dashboard
password: my_password
encoding: utf8
adapter: mysql
EOF
chmod 660 /usr/share/puppet-dashboard/config/database.yml

# Deploy the database
sed -i 's/max_allowed_packet.*/max_allowed_packet = 32M/g' /etc/mysql/my.cnf
service mysql restart
rake RAILS_ENV=production db:migrate

# Set up the apache configs for puppetmaster and dashboard
# IMPORTANT: Replace <host> below with the host id of the machine (e.g., e45d901c-8fc4-4e87-b761-2195b14b067f, or whatever you changed it to)
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

SSLCertificateFile      /var/lib/puppet/ssl/certs/<host>.pem
SSLCertificateKeyFile   /var/lib/puppet/ssl/private_keys/<host>.pem
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
chmod 0666 /usr/share/puppet-dashboard/log/production.log
service puppet-dashboard-workers start

echo "Puppet master setup complete. Hilary puppet config is found in /etc/puppet/puppet-hilary"
