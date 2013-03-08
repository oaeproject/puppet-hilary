node basenode {
  # The localconfig module is found in $environment/modules
  include epel
  class { 'localconfig': }
}

node drivernode inherits basenode {
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

node linuxnode inherits basenode {
  
  ####################
  ## FIREWALL SETUP ##
  ####################

  # Allow outgoing traffic and disallow any passthroughs
  # iptables -P INPUT DROP
  # iptables -P OUTPUT ACCEPT
  # iptables -P FORWARD DROP

  iptables { '000 base input':
    chain   => 'INPUT',
    jump    => 'ACCEPT'
  }

  iptables { '000 base output':
    chain   => 'OUTPUT',
    jump    => 'ACCEPT'
  }

  iptables { '000 base forward':
    chain   => 'FORWARD',
    jump    => 'ACCEPT'
  }

  # Allow traffic already established to continue
  # iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

  iptables { '001 continue':
    chain   => 'INPUT',
    state   => ['ESTABLISHED', 'RELATED'],
    jump    => 'ACCEPT',
  }

  # Allow ssh
  # iptables -A INPUT -p tcp --dport ssh -j ACCEPT
  # iptables -A INPUT -p tcp --dport domain -j ACCEPT

  iptables { '002 ssh':
    chain   => 'INPUT',
    proto   => 'tcp',
    dport   => 'ssh',
    jump    => 'ACCEPT',
  }
}

node appnode inherits basenode {

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
    require             => Class['nfs']
  }

  class { 'nfs':
    mountpoint => '/shared',
    server     => $localconfig::nfs_server,
    sourcedir  => $localconfig::nfs_sourcedir,
  }

}

node activitynode inherits basenode {

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
    enable_activities   => true,
    enable_previews     => false,
  }

  # These don't actually use the shared dir, but the hilary class needs it to exist
  file { '/shared':
    ensure => 'directory',
    before => Class['hilary']
  }
}

node ppnode inherits linuxnode {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  package { 'libreoffice':
    ensure  => installed,
  }

  package { 'pdftk':
    ensure  => installed,
  }

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
    os_user             => $localconfig::pp_user,
    os_group            => $localconfig::pp_group,
    upload_files_dir    => $localconfig::app_files,
    enable_activities   => false,
    enable_previews     => true,
    provider            => 'apt',
  }

  # These don't actually use the shared dir, but the hilary class needs it to exist
  file { '/shared':
    ensure => 'directory',
    before => Class['hilary']
  }
}

node webnode inherits basenode {

  ##################################
  ## INSTALL PACKAGE DEPENDENCIES ##
  ##################################

  package { 'gcc47':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'gmake':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'automake':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'nodejs':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'scmgit':
    ensure    => present,
    provider  => pkgin,
  }

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { $localconfig::ux_root:
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${localconfig::ux_git_user}/3akai-ux",
    revision  => $localconfig::ux_git_branch,
    require   => Package['scmgit'],
  }

  class { 'nginx':
    internal_app_ips  => $localconfig::app_hosts_internal,
    ux_home           => $localconfig::ux_root,
    ux_admin_host     => $localconfig::ux_admin_host,
    files_home        => $localconfig::app_files,
  }

  class { 'nfs':
    mountpoint => '/shared',
    server     => $localconfig::nfs_server,
    sourcedir  => $localconfig::nfs_sourcedir,
  }
}

node dbnode inherits linuxnode {
  # Use devel package so we actually get the JDK..
  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }
}

node mqnode inherits linuxnode {
  class { 'rabbitmq': }
}
