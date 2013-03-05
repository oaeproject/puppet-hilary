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
    $enable_previews   = false,
    $provider          = 'pkgin',
    $service_name      = 'node-sakai-oae') {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  case $operatingsystem {
    debian, ubuntu: {
      $packages = [ 'gcc', 'automake', 'nodejs', 'npm', 'graphicsmagick', 'git' ]
      $npm_binary = '/usr/bin/npm'
    }
    solaris: {
      $packages = [ 'gcc47', 'automake', 'gmake', 'nodejs', 'GraphicsMagick', 'scmgit' ]
      $npm_binary = '/opt/local/bin/npm'
    }
    default: {
      $packages = [ 'gcc', 'automake', 'gmake', 'nodejs', 'npm', 'GraphicsMagick', 'git' ]
      $npm_binary = '/usr/bin/npm'
    }
  }

  package { $packages:
    ensure    => present,
    provider  => $provider,
  }

  ########################
  ## DEPLOY APPLICATION ##
  ########################

  # git clone http://github.com/sakaiproject/Hilary
  vcsrepo { $app_root_dir:
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${app_git_user}/Hilary",
    revision  => $app_git_branch,
  }

  file { $app_root_dir:
    ensure  => directory,
    mode    => "0644",
    owner   => $os_user,
    group   => $os_group,
    recurse => true,
    require => Vcsrepo[$app_root_dir],
  }

  # npm install -d
  exec { "npm_install_dependencies":
    cwd         => $app_root_dir,
    command     => "${npm_binary} install -d",
    require     => [ File[$app_root_dir], Package[$packages], Vcsrepo[$app_root_dir] ],
    logoutput   => "on_failure",
  }

  # Directory for temp files
  file { $upload_files_dir:
    ensure  => directory,
    owner   => $os_user,
    group   => $os_group,
  }

  # config.js
  file { "${app_root_dir}/config.js":
    ensure  => present,
    content => template('localconfig/config.js.erb'),
    require => [ Vcsrepo[$app_root_dir], File[$upload_files_dir] ],
  }



  ####################
  ## CLONE 3AKAI-UX ##
  ####################

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { $ux_root_dir:
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${ux_git_user}/3akai-ux",
    revision  => $ux_git_branch,
  }



  #######################
  ## START APPLICATION ##
  #######################

  case $operatingsystem {
    debian, ubuntu: {

      file { "/etc/init/hilary.conf":
        ensure  =>  present,
        content =>  template('localconfig/upstart_hilary.conf.erb'),
        require =>  Vcsrepo[$app_root_dir],
      }

      # Create a symlink to /etc/init/*.conf in /etc/init.d, because Puppet 2.7 looks there incorrectly (see: http://projects.puppetlabs.com/issues/14297)
      file { '/etc/init.d/hilary':
        ensure => link,
        target => '/lib/init/hilary',
        require =>  File["/etc/init/hilary.conf"],
      }

      service { 'hilary':
        ensure   => running,
        provider => 'upstart',
        require  => [ File['/etc/init.d/hilary'],
                      Vcsrepo[$ux_root_dir],
                      Exec["npm_install_dependencies"],
                    ]
      }
    }
    solaris: {
      # Daemon script needed for SMF to manage the application
      file { "${app_root_dir}/service.xml":
        ensure  =>  present,
        content =>  template('localconfig/node-oae-service-manifest.xml.erb'),
        notify  =>  Exec["svccfg_${service_name}"],
        require =>  Vcsrepo[$app_root_dir],
      }

      # Force reload the manifest
      exec { "svccfg_${service_name}":
        command   => "/usr/sbin/svccfg import ${app_root_dir}/service.xml",
        notify    => Service[$service_name],
        require   => File["${app_root_dir}/service.xml"],
      }

      # Start the app server
      service { $service_name:
        ensure   => running,
        manifest => "${app_root_dir}/service.xml",
        require  => [ Exec["svccfg_${service_name}"],
                      Vcsrepo[$ux_root_dir],
                      Exec["npm_install_dependencies"],
                    ]
      }
    }
    default: {
      exec { "notsupported":
        command   => fail("No support yet for ${::operatingsystem}")
      }
    }
  }
}
