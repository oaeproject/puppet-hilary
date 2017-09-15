class oaeservice::puppet {

  # Configure puppetdb and its underlying database
  class { 'puppetdb': database  => 'embedded' }

  # Tell puppetmaster to use puppetdb
  class { 'puppetdb::master::config':
    puppetdb_server => 'puppet',
  }

  # clean puppet report logs
  # the report dir is not in puppet-hilary anywhere so extracted direct from puppet.conf
  cron { 'clean-puppet-reports':
    ensure  => present,
    command => "find $(awk -F= '/^reportdir/ { print $2 }' /etc/puppet/puppet.conf) -type f -iname \*.yaml -ctime +30 -delete",
    user    => 'root',
    hour    => '3',
    weekday => 'Sunday',
  }
}

