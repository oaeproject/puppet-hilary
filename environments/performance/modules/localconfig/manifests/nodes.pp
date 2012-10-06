
###############
## WEB PROXY ##
###############

node 'web0' inherits basenode {
  class { 'nginx':
    tenantsHash =>  {
        'global' => {
        
            ## This is temporary. Once we have a DNS entry, this would be something like: *.oae-performance.sakaiproject.org
            'host' => $localconfig::web_hosts[0],
            'port' => 2000
          },
          
        ## Example tenant mapping. We will add more here once we have DNS entries working
        't1' => {
            'host' => 't1.oae-performance.sakaiproject.org',
            'port' => 2001
          },
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
}

node 'db1' inherits dbnode {
  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[1],
    cluster_name    => $localconfig::db_cluster_name,
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
}