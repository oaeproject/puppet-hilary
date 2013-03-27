node basenodecommon {
  # The localconfig module is found in $environment/modules
  include epel
  class { 'localconfig': }
}

node drivernodecommon inherits basenodecommon {
  class { 'tsung': }

  package { 'nginx':
    ensure    => present,
    provider  => pkgin,
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }
}

node linuxnodecommon inherits basenodecommon {
  
  ####################
  ## FIREWALL SETUP ##
  ####################
  #
  # By default, allow:
  #
  #   1.  Drop invalid packets
  #   2.  everything on private and loopback interfaces, and established input traffic
  #   3.  all outgoing traffic, including public interfaces
  #
  # By default, deny:
  #
  #   4. all incoming and forward traffic not white-listed above
  #
  # It is expected that any node that needs additional firewall rules opened will specify a rule with a
  # "jump => 'ACCEPT'", with a resource name that is greater than 000 and less than 900. E.g.: to open
  # https traffic on the elasticsearch public interface (for some reason), in your class manifest, include:
  #
  # iptables { '001 elasticsearch http':
  #   chain => 'INPUT',
  #   dport => 'https',
  #   jump  => 'ACCEPT',
  # }
  #

  # 1.
  iptables { '000 kill invalid input on public':
    chain     => 'INPUT',
    iniface   => 'eth0',
    state     => 'INVALID',
    jump      => 'DROP',
  }

  iptables { '000 kill invalid forward on public':
    chain     => 'FORWARD',
    iniface   => 'eth0',
    state     => 'INVALID',
    jump      => 'DROP',
  }

  iptables { '000 kill invalid output on public':
    chain     => 'OUTPUT',
    outiface  => 'eth0',
    state     => 'INVALID',
    jump      => 'DROP',
  }

  # 2.
  iptables { '998 allow private input': chain => 'INPUT', iniface => 'eth1', jump => 'ACCEPT', }
  iptables { '998 allow private forward': chain => 'FORWARD', iniface => 'eth1', jump => 'ACCEPT' }
  iptables { '998 allow lo input': chain => 'INPUT', iniface => 'lo', jump => 'ACCEPT', }
  iptables { '998 allow lo forward': chain => 'FORWARD', iniface => 'lo', jump => 'ACCEPT' }
  iptables { '998 allow public established input':
    chain => 'INPUT',
    iniface => 'eth0',
    state => ['ESTABLISHED', 'RELATED'],
    jump => 'ACCEPT',
  }

  # 3.
  iptables { '999 allow base output': chain => 'OUTPUT', jump => 'ACCEPT' }

  # 4.
  iptables { '999 block base input': chain => 'INPUT', jump => 'DROP' }
  iptables { '999 block base forward': chain => 'FORWARD', jump => 'DROP' }

}

node hilarynodecommon inherits basenodecommon {

  # Hilary always requires this directory
  file { $localconfig::app_files_parent:
    ensure => 'directory',
    before => Class['hilary']
  }

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

    config_cassandra_hosts           => $localconfig::db_hosts,
    config_cassandra_keyspace        => $localconfig::db_keyspace,
    config_cassandra_timeout         => $localconfig::db_timeout,
    config_cassandra_replication     => $localconfig::db_replication,
    config_cassandra_strategy_class  => $localconfig::db_strategyClass,
    config_redis_hosts               => $localconfig::redis_hosts[0],
    config_servers_admin_host        => $localconfig::ux_admin_host,
    config_cookie_secret             => $localconfig::cookie_secret,
    config_telemetry_circonus_url    => $localconfig::circonus_url,
    config_search_hosts              => $localconfig::search_hosts_internal,
    config_mq_host                   => $localconfig::mq_hosts_internal[0]['host'],
    config_mq_port                   => $localconfig::mq_hosts_internal[0]['port'],
    config_signing_key               => $localconfig::app_sign_key,
    config_etherpad_hosts            => $localconfig::etherpad_hosts_internal,
    config_etherpad_api_key          => $localconfig::etherpad_api_key,
    config_etherpad_domain_suffix    => $localconfig::etherpad_domain_suffix,
  }
}

node appnodecommon inherits hilarynodecommon {
  # App node needs to mount the files
  class { 'files-nfs':
    name        => 'smartosnfs',
    mountpoint  => $localconfig::app_files_parent,
    server      => $localconfig::files_nfs_server,
    sourcedir   => $localconfig::files_nfs_sourcedir,
    before      => Class['hilary'],
    require     => File[$localconfig::app_files_parent],
  }
}

node activitynodecommon inherits hilarynodecommon {
  # Simply flick activities to be enabled
  Class['hilary'] { config_activity_enabled => true }
}

node ppnodecommon inherits hilarynodecommon {
  include linuxnodecommon

  package { 'libreoffice': ensure => installed }
  package { 'pdftk': ensure => installed }

  # Enable previews
  Class['hilary'] {
    config_enable_previews  => true,
    provider                => 'apt',
  }

}

node webnodecommon inherits basenodecommon {

  ##################################
  ## INSTALL PACKAGE DEPENDENCIES ##
  ##################################

  package { 'gcc47':    ensure => present, provider => pkgin }
  package { 'gmake':    ensure => present, provider => pkgin }
  package { 'automake': ensure => present, provider => pkgin }
  package { 'nodejs':   ensure => present, provider => pkgin }
  package { 'scmgit':   ensure => present, provider => pkgin }

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { $localconfig::ux_root:
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${localconfig::ux_git_user}/3akai-ux",
    revision  => $localconfig::ux_git_branch,
    require   => Package['scmgit'],
  }

  class { 'nginx':
    internal_app_ips      => $localconfig::app_hosts_internal,
    internal_etherpad_ips => $localconfig::etherpad_hosts_internal,
    ux_home               => $localconfig::ux_root,
    ux_admin_host         => $localconfig::ux_admin_host,
    files_home            => $localconfig::app_files,
  }

  class { 'files-nfs':
    name       => 'smartosnfs',
    mountpoint => $localconfig::app_files_parent,
    server     => $localconfig::files_nfs_server,
    sourcedir  => $localconfig::files_nfs_sourcedir,
  }
}

node dbnodecommon inherits linuxnodecommon {
  # Use devel package so we actually get the JDK..
  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }
}

node searchnodecommon inherits linuxnodecommon {
  class { 'elasticsearch':
    path_data     => $localconfig::search_path_data,
    max_memory_mb => 3072,
    min_memory_mb => 3072,
  }
}

node epnodecommon inherits basenodecommon {
  class { 'etherpad':
    etherpad_git_revision => '8b7db49f9c9f24ea7fe3554da42f335cfee33385',
    ep_oae_revision       => 'c0206b72ba4c2f5344a84f6e6529cf218ac7bec5',
    api_key               => $localconfig::etherpad_api_key,
  }
}

node syslognodecommon inherits linuxnodecommon {
  class { 'rsyslog':
    clientOrServer  => 'server',
    server_host     => $localconfig::rsyslog_host_internal,
    server_logdir   => $localconfig::rsyslog_server_logdir,
  }
}
