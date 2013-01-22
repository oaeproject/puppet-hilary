node basenode {
  # The localconfig module is found in $environment/modules
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
    enable  => 'true',
    require => Package['nginx'],
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
  vcsrepo { "${localconfig::ux_root}":
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${localconfig::ux_git_user}/3akai-ux",
    revision  => "${localconfig::ux_git_branch}",
    require   => Package['scmgit'],
  }

  class { 'nginx':
    internal_app_ips  => $localconfig::app_hosts_internal,
    ux_home           => $localconfig::ux_root,
    ux_admin_host     => $localconfig::ux_admin_host,
    files_home        => $localconfig::app_files,
  }

}

node dbnode inherits basenode {
  # Use devel package so we actually get the JDK..
  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }
}

node mqnode inherits basenode {
  class { 'rabbitmq': }
}
