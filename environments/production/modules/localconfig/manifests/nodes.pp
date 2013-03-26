
###############
## WEB PROXY ##
###############

node prodwebnode inherits webnode {
  # Allow web traffic into public interface on web node
  class { 'ipfilter': rules => [ 'pass in quick on net0 proto tcp from any to any port=80 keep state' ] }
}

node 'web0' inherits prodwebnode { }

node 'web1' inherits prodwebnode { }


###############
## APP NODES ##
###############

node prodappnode inherits appnode {
  # Apply firewall
  class { 'ipfilter': }
}

node 'app0' inherits prodappnode { }

node 'app1' inherits prodappnode { }

node 'app2' inherits prodappnode { }

node 'app3' inherits prodappnode { }

####################
## ACTIVITY NODES ##
####################

node prodactivitynode inherits activitynode {
  # Apply firewall
  class { 'ipfilter': }
}

node 'activity0' inherits prodactivitynode { }

node 'activity1' inherits prodactivitynode { }

node 'activity2' inherits prodactivitynode { }

node 'activity3' inherits prodactivitynode { }

node 'activity4' inherits prodactivitynode { }

node 'activity5' inherits prodactivitynode { }

#####################
## CASSANDRA NODES ##
#####################

node 'db0' inherits dbnode {
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

node 'db1' inherits dbnode {
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

node 'db2' inherits dbnode {
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

node 'db3' inherits dbnode {
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

node 'db4' inherits dbnode {
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

node 'db5' inherits dbnode {
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

node 'search0' inherits linuxnode {
  class { 'elasticsearch':
    path_data     => $localconfig::search_path_data,
    host_address  => $localconfig::search_hosts_internal[0]['host'],
    host_port     => $localconfig::search_hosts_internal[0]['port'],
    max_memory_mb => 3072,
    min_memory_mb => 3072,
  }

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'search1' inherits linuxnode {
  class { 'elasticsearch':
    path_data     => $localconfig::search_path_data,
    host_address  => $localconfig::search_hosts_internal[1]['host'],
    host_port     => $localconfig::search_hosts_internal[1]['port'],
    max_memory_mb => 3072,
    min_memory_mb => 3072,
  }

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

#################
## REDIS NODES ##
#################

node prodcachenode inherits basenode {
  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'cache-master' inherits prodcachenode {
  class { 'redis': }
}

node 'cache-slave' inherits prodcachenode {
  class { 'redis': slave_of  => $localconfig::redis_hosts[0], }
}

node 'activity-cache-master' inherits prodcachenode {
  class { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3
  }
}

node 'activity-cache-slave' inherits prodcachenode {
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

node 'mq-master' inherits linuxnode {
  class { 'rabbitmq':
    listen_address  => $localconfig::mq_hosts_internal[0]['host'],
    listen_port     => $localconfig::mq_hosts_internal[0]['port'],
  }

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

#############################
## PREVIEW PROCESSOR NODES ##
#############################

node 'pp0' inherits ppnode { }

node 'pp1' inherits ppnode { }

node 'pp2' inherits ppnode { }

####################
## ETHERPAD NODES ##
####################

node prodepnode inherits basenode {
  # Apply firewall
  class { 'ipfilter': }
}

node 'ep0' inherits prodepnode {
  class { 'etherpad':
    listen_address        => $localconfig::etherpad_hosts_internal[0]
    etherpad_git_revision => '8b7db49f9c9f24ea7fe3554da42f335cfee33385',
    ep_oae_revision       => 'c0206b72ba4c2f5344a84f6e6529cf218ac7bec5',
    api_key               => $localconfig::etherpad_api_key,
  }
}

node 'ep1' inherits prodepnode {
  class { 'etherpad':
    listen_address        => $localconfig::etherpad_hosts_internal[1],
    etherpad_git_revision => '8b7db49f9c9f24ea7fe3554da42f335cfee33385',
    ep_oae_revision       => 'c0206b72ba4c2f5344a84f6e6529cf218ac7bec5',
    api_key               => $localconfig::etherpad_api_key,
  }
}

#################
## SYSLOG NODE ##
#################

node 'syslog' inherits syslognode { }

#############
## BASTION ##
#############

node 'bastion' inherits linuxnode {

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
