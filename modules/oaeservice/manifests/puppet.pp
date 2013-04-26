class oaeservice::puppet {

  # Configure puppetdb and its underlying database
  class { 'puppetdb':
    database  => 'embedded',
  }

  # Tell puppetmaster to use puppetdb
  class { 'puppetdb::master::config': }
}