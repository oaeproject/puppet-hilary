
################
################
## BLUEPRINTS ##
################
################

node app inherits appnodecommon {
  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal }

  Class['hilary'] { config_log_syslog_ip => $localconfig::rsyslog_host_internal }
}

node activity inherits activitynodecommon {
  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }

  Class['hilary'] { config_log_syslog_ip => $localconfig::rsyslog_host_internal }
}

node db inherits dbnodecommon {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node web inherits webnodecommon {
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

node search inherits searchnodecommon {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

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

node cache inherits basenodecommon {
  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal }
}

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

node mq inherits linuxnodecommon {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal }
}

node 'mq-master' inherits mq {
  class { 'rabbitmq':
    listen_address  => $localconfig::mq_hosts_internal[0]['host'],
    listen_port     => $localconfig::mq_hosts_internal[0]['port'],
  }
}

#############################
## PREVIEW PROCESSOR NODES ##
#############################

node pp inherits ppnodecommon {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal }
  Class['hilary'] { config_log_syslog_ip => $localconfig::rsyslog_host_internal }
}

node 'pp0' inherits pp { }

node 'pp1' inherits pp { }

node 'pp2' inherits pp { }

####################
## ETHERPAD NODES ##
####################

node ep inherits epnodecommon {
  class { 'ipfilter': }
}

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

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal }
}
