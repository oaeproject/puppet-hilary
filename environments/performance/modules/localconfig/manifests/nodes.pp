
###############
## WEB PROXY ##
###############

node 'web0' inherits webnode { }


###############
## APP NODES ##
###############

node 'app0' inherits appnode { }

node 'app1' inherits appnode { }

node 'app2' inherits appnode { }

node 'app3' inherits appnode { }

####################
## ACTIVITY NODES ##
####################

node 'activity0' inherits activitynode { }

node 'activity1' inherits activitynode { }

node 'activity2' inherits activitynode { }

node 'activity3' inherits activitynode { }

node 'activity4' inherits activitynode { }

node 'activity5' inherits activitynode { }

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

node 'search0' inherits basenode {
  class { 'elasticsearch':
    path_data     => $localconfig::search_path_data,
    host_address  => $localconfig::search_hosts_internal[0]['host'],
    host_port     => $localconfig::search_hosts_internal[0]['port'],
    max_memory_mb => 3072,
    min_memory_mb => 3072,
  }
}

node 'search1' inherits basenode {
  class { 'elasticsearch':
    path_data     => $localconfig::search_path_data,
    host_address  => $localconfig::search_hosts_internal[1]['host'],
    host_port     => $localconfig::search_hosts_internal[1]['port'],
    max_memory_mb => 3072,
    min_memory_mb => 3072,
  }
}

#################
## REDIS NODES ##
#################

node 'cache0' inherits basenode {
  class { 'redis': }
}

node 'activity-cache' inherits basenode {
  class { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3
  }
}

#################
## LOAD DRIVER ##
#################

node 'driver0' inherits drivernode {
}

#####################
## MESSAGING NODES ##
#####################

node 'mq0' inherits mqnode {
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

node 'ep0' inherits basenode {
  class { 'etherpad':
    listen_address        => $localconfig::etherpad_hosts_internal[0],
    etherpad_git_revision => '8b7db49f9c9f24ea7fe3554da42f335cfee33385',
    ep_oae_revision       => 'c0206b72ba4c2f5344a84f6e6529cf218ac7bec5',
    api_key               => $localconfig::etherpad_api_key,
  }
}

node 'ep1' inherits basenode {
  class { 'etherpad':
    listen_address        => $localconfig::etherpad_hosts_internal[1],
    etherpad_git_revision => '8b7db49f9c9f24ea7fe3554da42f335cfee33385',
    ep_oae_revision       => 'c0206b72ba4c2f5344a84f6e6529cf218ac7bec5',
    api_key               => $localconfig::etherpad_api_key,
  }
}
