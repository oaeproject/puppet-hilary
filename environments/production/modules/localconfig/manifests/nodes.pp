
################
################
## BLUEPRINTS ##
################
################

node app inherits appnodecommon {

  ###########################################
  ## INSTALL HILARY AND 3AKAI-UX CONTAINER ##
  ###########################################

  class { 'hilary':
    app_root_dir        => $localconfig::app_root,
    app_git_user        => $localconfig::app_git_user,
    app_git_branch      => $localconfig::app_git_branch,
    ux_root_dir         => $localconfig::ux_root,
    ux_git_user         => $localconfig::ux_git_user,
    ux_git_branch       => $localconfig::ux_git_branch,
    os_user             => $localconfig::app_user,
    os_group            => $localconfig::app_group,
    upload_files_dir    => $localconfig::app_files,

    config_cassandra_hosts           => localconfig::db_hosts,
    config_cassandra_keyspace        => localconfig::db_keyspace,
    config_cassandra_timeout         => localconfig::db_timeout,
    config_cassandra_replication     => localconfig::db_replication,
    config_cassandra_strategy_class  => localconfig::db_strategyClass,
    config_redis_hosts               => localconfig::redis_hosts[0],
    config_servers_admin_host        => localconfig::ux_admin_host,
    config_cookie_secret             => localconfig::cookie_secret,
    config_telemetry_circonus_url    => localconfig::cironus_url,
    config_search_hosts              => localconfig::search_hosts_internal,
    config_mq_host                   => localconfig::mq_hosts_internal[0].host,
    config_mq_port                   => localconfig::mq_hosts_internal[0].port,
    config_signing_key               => localconfig::app_sign_key,
    config_etherpad_hosts            => localconfig::etherpad_hosts_internal,
    config_etherpad_api_key          => localconfig::etherpad_api_key,
    config_etherpad_domain_suffix    => localconfig::ehterpad_domain_suffix,

    require             => Class['files-nfs']
  }

  # These don't actually use the shared dir, but the hilary class needs it to exist
  file { '/shared':
    ensure => 'directory',
    before => Class['hilary']
  }


  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}


###############
## WEB PROXY ##
###############

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

node 'web0' inherits web { }

node 'web1' inherits web { }


###############
## APP NODES ##
###############

node app inherits appnodecommon {
  
}

node 'app0' inherits app { }

node 'app1' inherits app { }

node 'app2' inherits app { }

node 'app3' inherits app { }

####################
## ACTIVITY NODES ##
####################

node activity inherits activitynodecommon {
  # Apply firewall
  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'activity0' inherits activity { }

node 'activity1' inherits activity { }

node 'activity2' inherits activity { }

node 'activity3' inherits activity { }

node 'activity4' inherits activity { }

node 'activity5' inherits activity { }

#####################
## CASSANDRA NODES ##
#####################

node db inherits dbnodecommon {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

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

node search inherits linuxnodecommon {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'search0' inherits search {
  class { 'elasticsearch':
    path_data     => $localconfig::search_path_data,
    host_address  => $localconfig::search_hosts_internal[0]['host'],
    host_port     => $localconfig::search_hosts_internal[0]['port'],
    max_memory_mb => 3072,
    min_memory_mb => 3072,
  }
}

node 'search1' inherits search {
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

node cache inherits basenodecommon {
  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'cache-master' inherits cache {
  class { 'redis': }
}

node 'cache-slave' inherits cache {
  class { 'redis': slave_of  => $localconfig::redis_hosts[0], }
}

node 'activity-cache-master' inherits cache {
  class { 'redis':
    eviction_maxmemory  => 3758096384,
    eviction_policy     => 'volatile-ttl',
    eviction_samples    => 3
  }
}

node 'activity-cache-slave' inherits cache {
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

node mq inherits linuxnodecommon {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
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

node pp {
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node 'pp0' inherits pp { }

node 'pp1' inherits pp { }

node 'pp2' inherits pp { }

####################
## ETHERPAD NODES ##
####################

node ep inherits basenodecommon {
  # Apply firewall
  class { 'ipfilter': }
}

node 'ep0' inherits ep {
  class { 'etherpad':
    listen_address        => $localconfig::etherpad_hosts_internal[0]
    etherpad_git_revision => '8b7db49f9c9f24ea7fe3554da42f335cfee33385',
    ep_oae_revision       => 'c0206b72ba4c2f5344a84f6e6529cf218ac7bec5',
    api_key               => $localconfig::etherpad_api_key,
  }
}

node 'ep1' inherits ep {
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

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}
