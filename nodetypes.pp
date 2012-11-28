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
  
  
  
  ########################
  ## DEPLOY APPLICATION ##
  ########################
  
  # git clone http://github.com/sakaiproject/Hilary
  vcsrepo { "${localconfig::app_root}":
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${localconfig::app_git_user}/Hilary",
    revision  => "${localconfig::app_git_branch}",
    require   => Package['scmgit'],
  }
  
  # npm install -d
  exec { "npm_install_dependencies":
    cwd     => "${localconfig::app_root}",
    command => "/opt/local/bin/npm install -d",
    require => Vcsrepo["${localconfig::app_root}"],
  }

  # Directory for temp files
  file { "${localconfig::app_files}":
    ensure  => directory,
    owner   => "${localconfig::app_user}",
    group   => "${localconfig::app_group}",
  }
  
  # config.js
  file { "${localconfig::app_root}/config.js":
    ensure  => present,
    content => template('localconfig/config.js.erb'),
    notify  =>  Service[$localconfig::app_service_name],
    require => [ Vcsrepo["${localconfig::app_root}"], File["${localconfig::app_files}"] ],
  }
  
  
  
  #######################
  ## START APPLICATION ##
  #######################
  
  # Daemon script needed for SMF to manage the application
  file { "${localconfig::app_root}/service.xml":
    ensure  =>  present,
    content =>  template('localconfig/node-oae-service-manifest.xml.erb'),
    notify  =>  Exec["svccfg_${localconfig::app_service_name}"],
    require =>  Vcsrepo["${localconfig::app_root}"],
  }
  
  # Own everything as the application user. We need to make sure all file changes in the directory are done before setting this
  exec { "chown_${localconfig::app_root}":
    command => "/opt/local/gnu/bin/chown -R ${localconfig::app_user}:${localconfig::app_group} ${localconfig::app_root}",
    require => [Vcsrepo["${localconfig::app_root}"], File["${localconfig::app_root}/config.js"],
        File["${localconfig::app_root}/service.xml"], Exec["npm_install_dependencies"] ],
  }
  
  # Force reload the manifest
  exec { "svccfg_${localconfig::app_service_name}":
    command   => "/usr/sbin/svccfg import ${localconfig::app_root}/service.xml",
    notify    => Service["${localconfig::app_service_name}"],
    require   => File["${localconfig::app_root}/service.xml"],
  }
  
  # Start the app server
  service { "${localconfig::app_service_name}":
    ensure    => running,
    manifest  => "${localconfig::app_root}/service.xml",
    require => Exec["chown_${localconfig::app_root}"],
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
