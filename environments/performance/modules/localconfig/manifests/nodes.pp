
node openfirewalllinux {
  iptables { '001 allow all input':   chain => 'INPUT',   iniface => 'eth0', jump => 'ACCEPT' }
  iptables { '001 allow all forward': chain => 'FORWARD', iniface => 'eth0', jump => 'ACCEPT' }
}

###############
## WEB PROXY ##
###############

node 'web0' inherits webnodecommon { }

node 'web1' inherits webnodecommon { }

###############
## APP NODES ##
###############

node 'app0' inherits appnodecommon { }

node 'app1' inherits appnodecommon { }

node 'app2' inherits appnodecommon { }

node 'app3' inherits appnodecommon { }

####################
## ACTIVITY NODES ##
####################

node 'activity0' inherits activitynodecommon { }

node 'activity1' inherits activitynodecommon { }

node 'activity2' inherits activitynodecommon { }

#####################
## CASSANDRA NODES ##
#####################

node 'db0' inherits dbnodecommon {
  include openfirewalllinux
  
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

node 'db1' inherits dbnodecommon {
  include openfirewalllinux

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

node 'db2' inherits dbnodecommon {
  include openfirewalllinux

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

node 'db3' inherits dbnodecommon {
  include openfirewalllinux

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

node 'db4' inherits dbnodecommon {
  include openfirewalllinux

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

node 'db5' inherits dbnodecommon {
  include openfirewalllinux

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

node 'search0' inherits searchnodecommon {
  include openfirewalllinux

  Class['elasticsearch'] {
    host_address  => $localconfig::search_hosts_internal[0]['host'],
    host_port     => $localconfig::search_hosts_internal[0]['port'],
  }
}

node 'search1' inherits searchnodecommon {
  include openfirewalllinux

  Class['elasticsearch'] {
    host_address  => $localconfig::search_hosts_internal[1]['host'],
    host_port     => $localconfig::search_hosts_internal[1]['port'],
  }
}

#################
## REDIS NODES ##
#################

node 'cache-master' inherits basenodecommon {
  class { 'redis': }
}

node 'cache-slave' inherits basenodecommon {
  class { 'redis': slave_of => $localconfig::redis_hosts[0] }
}

node 'activity-cache-master' inherits basenodecommon {
  class { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3
  }
}

node 'activity-cache-slave' inherits basenodecommon {
  class { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3,
    slave_of            => $localconfig::activity_redis_hosts[0]
  }
}

#####################
## MESSAGING NODES ##
#####################

node 'mq-master' inherits linuxnodecommon {
  class { 'rabbitmq':
    listen_address  => $localconfig::mq_hosts_internal[0]['host'],
    listen_port     => $localconfig::mq_hosts_internal[0]['port'],
  }
}

#############################
## PREVIEW PROCESSOR NODES ##
#############################

node 'pp0' inherits ppnodecommon { include openfirewalllinux }

node 'pp1' inherits ppnodecommon { include openfirewalllinux }

node 'pp2' inherits ppnodecommon { include openfirewalllinux }

####################
## ETHERPAD NODES ##
####################

node 'ep0' inherits epnodecommon {
  Class['etherpad'] { listen_address => $localconfig::etherpad_hosts_internal[0] }
}

node 'ep1' inherits epnodecommon {
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
  include openfirewalllinux

  ## Allow forwarding with sysctl
  Exec { path => '/usr/bin:/usr/sbin/:/bin:/sbin' }
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
