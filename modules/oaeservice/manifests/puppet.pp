class oaeservice::puppet {

  # Configure puppetdb and its underlying database
  class { 'puppetdb':
    listen_port     => 8888,
    ssl_listen_port => 8889,
    database        => 'embedded',
  }

  # Tell puppetmaster to use puppetdb
  class { 'puppetdb::master::config':
    puppetdb_port   => 8889,
  }

  # Accept SSH traffic on the public interface
  iptables { '001 allow public ssh traffic':
    chain   => 'INPUT',
    iniface => 'eth0',
    proto   => 'tcp',
    dport   => 22,
    jump    => 'ACCEPT',
  }
}