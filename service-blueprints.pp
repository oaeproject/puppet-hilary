
########################
########################
## SERVICE BLUEPRINTS ##
########################
########################

##
# "Service Blueprints", in contrast to "Machine Blueprints" are high-level class definitions that
# represent pre-canned class definitions. These are useful to inherit and override for nodes that
# may share a service and most of the config, but need to override just a couple properties. Most
# common when you have many different environments.
#
# TODO: A service::ui can probably be extracted away from both service::hilary and service::nginx
# as stand-alone service. Then you add service::nginx or service::hilary to make it useful.
##

class service { }


#######################
## HILARY BLUEPRINTS ##
#######################

class service::hilary::base {
  hilary { 'hilary':
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
    config_redis_hosts               => $localconfig::redis_hosts,
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

  ## Any node that has hilary is going to need this directory
  file { $localconfig::app_files_parent:
    ensure => 'directory',
    before => Hilary['hilary']
  }
}

class service::hilary::activity inherits service::hilary::base {
  Hilary['hilary'] {
    config_activity_enabled => true,
  }
}

class service::hilary::pp inherits service::hilary::base {
  package { 'libreoffice': ensure => installed }
  package { 'pdftk': ensure => installed }

  Hilary['hilary'] {
    config_enable_previews  => true,
    os_user                 => 'root',
    os_group                => 'root',
    requires                => [ Package['libreoffice'], Package['pdftk'] ],
  }
}

class service::hilary::app inherits service::hilary::base {
  smartosnfs { $localconfig::app_files_parent:
    server     => $localconfig::files_nfs_server,
    sourcedir  => $localconfig::files_nfs_sourcedir,
  }
}

define service::hilary {
  include service::hilary::base
}



##############################
## ELASTICSEARCH BLUEPRINTS ##
##############################

define service::elasticsearch ($index) {
  elasticsearch { 'elasticsearch':
    host_address  => $localconfig::search_hosts_internal[$index]['host'],
    host_port     => $localconfig::search_hosts_internal[$index]['port'],
    path_data     => $localconfig::search_path_data,
    max_memory_mb => $localconfig::search_memory_mb,
    min_memory_mb => $localconfig::search_memory_mb,
  }
}



##########################
## CASSANDRA BLUEPRINTS ##
##########################

define service::cassandra ($index) {
  package { 'java-1.6.0-openjdk-devel': ensure => installed }

  cassandra { 'cassandra':
    owner           => $localconfig::db_user,
    group           => $localconfig::db_group,
    hosts           => $localconfig::db_hosts,
    listen_address  => $localconfig::db_hosts[$index],
    cluster_name    => $localconfig::db_cluster_name,
    initial_token   => $localconfig::db_initial_tokens[$index],
    require         => Package['java-1.6.0-openjdk-devel']
  }
}




#########################
## ETHERPAD BLUEPRINTS ##
#########################

define service::etherpad ($index) {
  etherpad { 'etherpad':
    listen_address        => $localconfig::etherpad_hosts_internal[$index],
    etherpad_git_revision => $localconfig::etherpad_git_revision,
    etherpad_oae_revision => $localconfig::etherpad_oae_revision,
    api_key               => $localconfig::etherpad_api_key,
  }
}



######################
## NGINX BLUEPRINTS ##
######################

define service::nginx {
  
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

  nginx { 'nginx':
    internal_app_ips      => $localconfig::app_hosts_internal,
    internal_etherpad_ips => $localconfig::etherpad_hosts_internal,
    ux_home               => $localconfig::ux_root,
    ux_admin_host         => $localconfig::ux_admin_host,
    files_home            => $localconfig::app_files,
  }

  smartosnfs { $localconfig::app_files_parent:
    server     => $localconfig::files_nfs_server,
    sourcedir  => $localconfig::files_nfs_sourcedir,
  }
}



#########################
## FIREWALL BLUEPRINTS ##
#########################

## Base firewall definitions
class service::firewall {

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

## An open firewall that can be included for convenience
class service::firewall::open {
  iptables { '001 allow all input':   chain => 'INPUT',   iniface => 'eth0', jump => 'ACCEPT' }
  iptables { '001 allow all forward': chain => 'FORWARD', iniface => 'eth0', jump => 'ACCEPT' }
}



########################
## RSYSLOG BLUEPRINTS ##
########################

class service::rsyslog { }

define service::rsyslog::server {
  rsyslog { 'rsyslog':
    clientOrServer  => 'server',
    server_host     => $localconfig::rsyslog_host_internal,
    server_logdir   => $localconfig::rsyslog_server_logdir,
  }
}

define service::rsyslog::client ($imfiles = false) {
  rsyslog { 'rsyslog':
    clientOrServer  => 'client',
    server_host     => $localconfig::rsyslog_host_internal,
    server_logdir   => $localconfig::rsyslog_server_logdir,
    imfiles         => $imfiles,
  }
}



######################
## MUNIN BLUEPRINTS ##
######################

class service::munin { }

define service::munin::client ($type_code, $suffix = '') {
  notify { "Type code: ${type_code}; Suffix: ${suffix}":
    before => Munin::Client['munin-client']
  }

  munin::client { 'munin-client': hostname => "${type_code}${suffix}" }
}
