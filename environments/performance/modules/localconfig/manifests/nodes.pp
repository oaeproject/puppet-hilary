
###############
## WEB PROXY ##
###############

node 'web0' inherits basenode {
  class { 'nginx':
    tenantsHash =>  {
        'global' => {
            'host' => 'global.oae-performance.sakaiproject.org',
            'port' => 2000
        },


        't1' => {
            'host' => 't1.oae-performance.sakaiproject.org',
            'port' => 2001
        },
        't2' => {
            'host' => 't2.oae-performance.sakaiproject.org',
            'port' => 2002
        },
        't3' => {
            'host' => 't3.oae-performance.sakaiproject.org',
            'port' => 2003
        },
        't4' => {
            'host' => 't4.oae-performance.sakaiproject.org',
            'port' => 2004
        },
        't5' => {
            'host' => 't5.oae-performance.sakaiproject.org',
            'port' => 2005
        }
    },
    internal_app_ips  => $localconfig::app_hosts_internal,
  }
}



###############
## APP NODES ##
###############

node 'app0' inherits appnode {
  # App 0 also hosts redis
  class { 'redis': }
}

node 'app1' inherits appnode { }



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
  }

  class { 'munin::client':
    hostname => 'db2',
    require  => Class['cassandra::common'],
  }
}

#################
## LOAD DRIVER ##
#################

node 'driver0' inherits drivernode {
}
