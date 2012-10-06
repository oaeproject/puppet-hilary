node basenode {
  # The localconfig module is found in $environment/modules
  class { 'localconfig': }
}

node appnode inherits basenode {

  # Install compiler tools
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

  # Install node js
  package { 'nodejs':
    ensure    => present,
    provider  => pkgin,
  }
  
  # Install git
  package { 'scmgit':
    ensure    => present,
    provider  => pkgin,
  }
  
  # Checkout code
  vcsrepo { "${localconfig::app_root}":
    ensure    => present,
    provider  => git,
    source    => "http://www.github.com/${localconfig::app_git_user}/Hilary",
    revision  => "${localconfig::app_git_branch}",
    require   => Package['scmgit'],
  }
  
  # Configure the app
  file { "${localconfig::app_root}/config.js":
    ensure  => present,
    content => template('localconfig/config.js.erb'),
    notify  =>  Service['node-sakai-oae'],
    require => Vcsrepo["${localconfig::app_root}"],
  }
  
  # Drop in the service manifest
  file { "${localconfig::app_root}/service.xml":
    ensure  =>  present,
    content =>  template('localconfig/node-oae-service-manifest.xml.erb'),
    notify  =>  Service['node-sakai-oae'],
    require => Vcsrepo["${localconfig::app_root}"],
  }
  
  # Install dependencies
  exec { "npm_install_dependencies":
    cwd     => "${localconfig::app_root}",
    command => "/opt/local/bin/npm install -d",
  }
  
  # Own everything as the application user. We need to make sure all file changes in the directory are done before setting this
  exec { "chown_${localconfig::app_root}":
    command => "/opt/local/gnu/bin/chown -R ${localconfig::app_user}:${localconfig::app_group} ${localconfig::app_root}",
    require => [Vcsrepo["${localconfig::app_root}"], File["${localconfig::app_root}/config.js"],
        File["${localconfig::app_root}/service.xml"], Exec["npm_install_dependencies"] ],
  }
  
  # Start the app server
  service { 'node-sakai-oae':
    ensure    => running,
    manifest  => "${localconfig::app_root}/service.xml",
    require => Exec["chown_${localconfig::app_root}"],
  }
}

node dbnode inherits basenode {
  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }
}