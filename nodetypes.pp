
node appnode {

  # The localconfig module is found in $environment/modules
  class { 'localconfig': }

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
  
  # Own code as the application user
  exec { "chown_${localconfig::app_root}":
    command => "/opt/local/gnu/bin/chown -R ${localconfig::app_user}:${localconfig::app_group} ${localconfig::app_root}",
    require => Vcsrepo["${localconfig::app_root}"],
  }
  
  # Configure the app
  file { "${localconfig::app_root}/config.js":
    ensure  => present,
    content => template('localconfig/config.js.erb'),
  }
  
  # Install dependencies
  exec { "npm_install_dependencies":
    cwd     => "${localconfig::app_root}",
    command => "/opt/local/bin/npm install -d",
    require => Exec["chown_${localconfig::app_root}"],
  }
  
  # Start the app server
  exec { "start_app":
    cwd     => "${localconfig::app_root}",
    command => "/opt/local/bin/node app.js > stdout.log &",
  }
}

node dbnode {

  # The localconfig module is found in $environment/modules
  class { 'localconfig': }

  package { 'java-1.6.0-openjdk':
    ensure  => installed,
  }
  
  class { 'cassandra::common':
    owner => $localconfig::app_user,
    group => $localconfig::app_group,
  }
  
}