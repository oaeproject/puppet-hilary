node 'app0' inherits appnode {

  class { 'redis': }
  
}

node 'app1' inherits appnode {

}

node 'db0' inherits dbnode {

  class { 'cassandra::common':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[0],
    cluster_name    => $localconfig::db_cluster_name,
  }

  class { 'opscenter':
    listen_address => $localconfig::db_hosts[0]
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