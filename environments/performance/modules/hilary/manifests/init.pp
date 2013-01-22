class hilary (
    $app_root_dir,
    $app_git_user,
    $app_git_branch,
    $ux_root_dir,
    $ux_git_user,
    $ux_git_branch,
    $os_user,
    $os_group,
    $upload_files_dir,
    $enable_activities = false,
    $service_name      = 'node-sakai-oae') {
  
  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

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

  package { 'GraphicsMagick':
    ensure    => present,
    provider  => pkgin,
  }



  ########################
  ## DEPLOY APPLICATION ##
  ########################

  # git clone http://github.com/sakaiproject/Hilary
  vcsrepo { "${app_root_dir}":
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${app_git_user}/Hilary",
    revision  => "${app_git_branch}",
    require   => [ Package['scmgit'] ],
  }
  
  # npm install -d
  exec { "npm_install_dependencies":
    cwd         => "${app_root_dir}",
    command     => "/opt/local/bin/npm install -d",
    require     => [ Vcsrepo["${app_root_dir}"], Package['GraphicsMagick'] ],
  }

  # Directory for temp files
  file { "${upload_files_dir}":
    ensure  => directory,
    owner   => "${os_user}",
    group   => "${os_group}",
  }
  
  # config.js
  file { "${app_root_dir}/config.js":
    ensure  => present,
    content => template('localconfig/config.js.erb'),
    notify  =>  Service["${service_name}"],
    require => [ Vcsrepo["${app_root_dir}"], File["${upload_files_dir}"] ],
  }



  ####################
  ## CLONE 3AKAI-UX ##
  ####################

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { "${ux_root_dir}":
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${ux_git_user}/3akai-ux",
    revision  => "${ux_git_branch}",
    require   => Package['scmgit'],
  }



  #######################
  ## START APPLICATION ##
  #######################
  
  # Daemon script needed for SMF to manage the application
  file { "${app_root_dir}/service.xml":
    ensure  =>  present,
    content =>  template('localconfig/node-oae-service-manifest.xml.erb'),
    notify  =>  Exec["svccfg_${service_name}"],
    require =>  Vcsrepo["${app_root_dir}"],
  }
  
  # Own everything as the application user. We need to make sure all file changes in the directory are done before setting this
  exec { "chown_${app_root_dir}":
    command => "/opt/local/gnu/bin/chown -R ${os_user}:${os_group} ${app_root_dir}",
    require => [Vcsrepo["${app_root_dir}"], File["${app_root_dir}/config.js"],
        File["${app_root_dir}/service.xml"], Exec["npm_install_dependencies"] ],
  }
  
  # Force reload the manifest
  exec { "svccfg_${service_name}":
    command   => "/usr/sbin/svccfg import ${app_root_dir}/service.xml",
    notify    => Service["${service_name}"],
    require   => File["${app_root_dir}/service.xml"],
  }
  
  # Start the app server
  service { "${service_name}":
    ensure    => running,
    manifest  => "${app_root_dir}/service.xml",
    require => [ Exec["chown_${app_root_dir}"], Vcsrepo["${ux_root_dir}"] ],
  }
  
}