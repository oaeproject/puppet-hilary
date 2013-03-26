
###############
## WEB PROXY ##
###############

node prodwebnode inherits webnode {
  # Allow web traffic into public interface on web node
  class { 'ipfilter': rules => [ 'pass in quick on net0 proto tcp from any to any port=80 keep state' ] }
  
  ## Rsyslog: Manually crunch the log files using the rsyslog "imfile" plugin
  class { 'rsyslog':
    server_host => $localconfig::rsyslog_host_internal,
    imfiles     => [

      # Access log
      {
        path                  => '/var/log/nginx/access.log',
        tag                   => 'access',
        state_file_name       => 'nginx_access',
        severity              => 'info',
        facility              => 'local0',
        poll_interval_seconds => 10,
      },

      # Error log
      {
        path                  => '/var/log/nginx/error.log',
        tag                   => 'error',
        state_file_name       => 'nginx_error',
        severity              => 'error',
        facility              => 'local1',
        poll_interval_seconds => 10,
      },
    ]
  }

  # Add a custom nginx log rotation entry into logadm
  # Solaris by default already has a cronjob that executes logadm on a regular basis
  file { '/etc/logadm.conf':
    ensure  => present,
    mode    => 0644,
    owner   => 'root',
    group   => 'root',
    content => template('localconfig/logadm.web.config.erb'),
  }
}

node 'web0' inherits prodwebnode { }

node 'web1' inherits prodwebnode { }


###############
## APP NODES ##
###############

node prodappnode inherits appnode {
  # Apply firewall
  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
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
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
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

node proddbnode inherits dbnode {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'db0' inherits proddbnode {
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

node 'db1' inherits proddbnode {
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

node 'db2' inherits proddbnode {
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

node 'db3' inherits proddbnode {
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

node 'db4' inherits proddbnode {
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

node 'db5' inherits proddbnode {
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

node prodsearchnode inherits linuxnode {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'search0' inherits prodsearchnode {
  class { 'elasticsearch':
    path_data     => $localconfig::search_path_data,
    host_address  => $localconfig::search_hosts_internal[0]['host'],
    host_port     => $localconfig::search_hosts_internal[0]['port'],
    max_memory_mb => 3072,
    min_memory_mb => 3072,
  }
}

node 'search1' inherits prodsearchnode {
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

node prodmqnode inherits linuxnode {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'mq-master' inherits prodmqnode {
  class { 'rabbitmq':
    listen_address  => $localconfig::mq_hosts_internal[0]['host'],
    listen_port     => $localconfig::mq_hosts_internal[0]['port'],
  }
}

#############################
## PREVIEW PROCESSOR NODES ##
#############################

node prodppnode {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'pp0' inherits prodppnode { }

node 'pp1' inherits prodppnode { }

node 'pp2' inherits prodppnode { }

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

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}
