
#############################
#############################
## COMMON NODE DEFINITIONS ##
#############################
#############################


###############
## BASE NODE ##
###############

node basenodecommon {
  # The localconfig module is found in $environment/modules
  include epel
  class { 'localconfig': }
}

##############
## WEB NODE ##
##############

node webnodecommon inherits basenodecommon {

  ## TODO: A lot of this will probably need to be extracted out to classes

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

node syslognodecommon inherits linuxnodecommon {
  class { 'rsyslog':
    clientOrServer  => 'server',
    server_host     => $localconfig::rsyslog_host_internal,
    server_logdir   => $localconfig::rsyslog_server_logdir,
  }
}
