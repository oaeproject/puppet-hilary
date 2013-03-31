
################
################
## BLUEPRINTS ##
################
################

###############
## WEB PROXY ##
###############

node 'web0' inherits web { }

node 'web1' inherits web { }

###############
## APP NODES ##
###############

node 'app0' inherits app { }

node 'app1' inherits app { }

node 'app2' inherits app { }

node 'app3' inherits app { }

####################
## ACTIVITY NODES ##
####################

node 'activity0' inherits activity { }

node 'activity1' inherits activity { }

node 'activity2' inherits activity { }

node 'activity3' inherits activity { }

node 'activity4' inherits activity { }

node 'activity5' inherits activity { }

#####################
## CASSANDRA NODES ##
#####################

node 'db0' inherits db {
  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[0],
    cluster_name    => $localconfig::db_cluster_name,
    initial_token   => $localconfig::db_initial_tokens[0],
  }

  class { 'opscenter':
    require => Class['cassandra::common'],
  }

  class { 'munin::client':
    hostname => 'db0',
    require  => Class['cassandra::common'],
  }
}

node 'db1' inherits db {
  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[1],
    cluster_name    => $localconfig::db_cluster_name,
    initial_token   => $localconfig::db_initial_tokens[1],
  }

  class { 'munin::client':
    hostname => 'db1',
    require  => Class['cassandra::common'],
  }
}

node 'db2' inherits db {
  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[2],
    cluster_name    => $localconfig::db_cluster_name,
    initial_token   => $localconfig::db_initial_tokens[2],
  }

  class { 'munin::client':
    hostname => 'db2',
    require  => Class['cassandra::common'],
  }
}

node 'db3' inherits db {
  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[3],
    cluster_name    => $localconfig::db_cluster_name,
    initial_token   => $localconfig::db_initial_tokens[3],
  }

  class { 'munin::client':
    hostname => 'db3',
    require  => Class['cassandra::common'],
  }
}

node 'db4' inherits db {
  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[4],
    cluster_name    => $localconfig::db_cluster_name,
    initial_token   => $localconfig::db_initial_tokens[4],
  }

  class { 'munin::client':
    hostname => 'db4',
    require  => Class['cassandra::common'],
  }
}

node 'db5' inherits db {
  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[5],
    cluster_name    => $localconfig::db_cluster_name,
    initial_token   => $localconfig::db_initial_tokens[5],
  }

  class { 'munin::client':
    hostname => 'db5',
    require  => Class['cassandra::common'],
  }
}

##################
## SEARCH NODES ##
##################

node 'search0' inherits search {
  Class['elasticsearch'] {
    host_address  => $localconfig::search_hosts_internal[0]['host'],
    host_port     => $localconfig::search_hosts_internal[0]['port'],
  }
}

node 'search1' inherits search {
  Class['elasticsearch'] {
    host_address  => $localconfig::search_hosts_internal[1]['host'],
    host_port     => $localconfig::search_hosts_internal[1]['port'],
  }
}

#################
## REDIS NODES ##
#################

node 'cache-master' inherits cache {
  class { 'redis': syslog_enabled => true }
}

node 'cache-slave' inherits cache {
  class { 'redis':
    syslog_enabled => true,
    slave_of => $localconfig::redis_hosts[0]
  }
}

node 'activity-cache-master' inherits cache {
  class { 'redis':
    syslog_enabled      => true,
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3
  }
}

node 'activity-cache-slave' inherits cache {
  class { 'redis':
    syslog_enabled      => true,
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3,
    slave_of            => $localconfig::activity_redis_hosts[0]
  }
}

#####################
## MESSAGING NODES ##
#####################

node 'mq-master' inherits mq {
  class { 'rabbitmq':
    listen_address  => $localconfig::mq_hosts_internal[0]['host'],
    listen_port     => $localconfig::mq_hosts_internal[0]['port'],
  }
}

#############################
## PREVIEW PROCESSOR NODES ##
#############################

node 'pp0' inherits pp { }

node 'pp1' inherits pp { }

node 'pp2' inherits pp { }

####################
## ETHERPAD NODES ##
####################

node 'ep0' inherits ep {
  Class['etherpad'] { listen_address => $localconfig::etherpad_hosts_internal[0] }
}

node 'ep1' inherits ep {
  Class['etherpad'] { listen_address => $localconfig::etherpad_hosts_internal[1] }
}

#################
## SYSLOG NODE ##
#################

node 'syslog' inherits syslognodecommon { }

#############
## BASTION ##
#############

node 'bastion' inherits linuxnodecommon {

  ## Allow forwarding with sysctl
  sysctl::value {
    'net.ipv4.ip_forward': value => '1',
    notify => Exec['load-sysctl'],
  }

  exec { 'load-sysctl':
    command => 'sysctl -p /etc/sysctl.conf',
    refreshonly => true,
  }

  ##########################
  ## SSH TRAFFIC HANDLING ##
  ##########################

  # Accept SSH traffic on the public interface
  iptables { '001 allow public ssh traffic':
    chain   => 'INPUT',
    iniface => 'eth0',
    proto   => 'tcp',
    dport   => 22,
    jump    => 'ACCEPT',
  }
}
