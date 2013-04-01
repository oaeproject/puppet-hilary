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
    $service_name       = 'node-sakai-oae',

    ############
    ## Config ##
    ############

    # Cassandra
    $config_cassandra_hosts,
    $config_cassandra_keyspace        = 'oae',
    $config_cassandra_timeout         = 3000,
    $config_cassandra_replication     = 1,
    $config_cassandra_strategy_class  = 'SimpleStrategy',

    # Redis
    $config_redis_host_master,

    # Servers
    $config_servers_admin_host,

    # Cookie
    $config_cookie_secret,

    # Logging
    $config_log_syslog_ip             = false,

    # Telemetry
    $config_telemetry_circonus_url,

    # Search
    $config_search_hosts,

    # RabbitMQ
    $config_mq_host,
    $config_mq_port                   = 5672,

    # Previews
    $config_previews_enabled          = false,

    # Signing
    $config_signing_key,

    # Activity
    $config_activity_enabled          = false,
    $config_activity_redis_host       = false,

    # Etherpad
    $config_etherpad_hosts,
    $config_etherpad_api_key,
    $config_etherpad_domain_suffix) {


  $nodegyp_version = '0.9.3'

  case $operatingsystem {
    debian, ubuntu: {
      # Crazy exact apt versioning
      $node_version = '0.8.22-1chl1~precise1'
      $npm_version = '1.2.14-1chl1~precise1'
    }
    default: {
      # SmartOS, at least. Not tested on centos
      $node_version = '0.8.22'
    }
  }

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  case $operatingsystem {
    debian, ubuntu: {
      $packages   = [ 'gcc', 'automake', "nodejs=$node_version", "npm=$npm_version", 'graphicsmagick', 'git' ]
      $provider   = undef

      # Apply apt configuration, which should be executed before these packages are installed
      class { 'apt': }

      apt::key { 'chris-lea':
        key       => '4BD6EC30',
        require   => Class['apt'],
        before    => Package[$packages],
      }

      apt::ppa { 'ppa:chris-lea/node.js':
        require   => Class['apt'],
        before    => Package[$packages],
      }
      
      apt::ppa { 'ppa:chris-lea/node.js-legacy':
        require   => Class['apt'],
        before    => Package[$packages],
      }
    }
    solaris, Solaris: {
      $packages   = [ 'gcc47', 'automake', 'gmake', "nodejs-$node_version", 'GraphicsMagick', 'scmgit' ]
      $provider   = 'pkgin'
    }
    default: {
      $packages   = [ 'gcc', 'automake', 'gmake', "nodejs-$node_version", 'npm', 'GraphicsMagick', 'git' ]
      $provider   = undef
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
    require => Vcsrepo[$app_root_dir],
  }

  # Force the npm bundled version of node-gyp to upgrade node-gyp. Needed to build node-expat and hiredis
  exec { 'npm_reinstall_nodegyp':
    command   => "npm explore npm -g -- npm install node-gyp@$nodegyp_version",
    logoutput => 'on_failure',
  }

  # npm install -d
  exec { "npm_install_dependencies":
    cwd         => $app_root_dir,

    # Forcing CFLAGS for std=c99 for hiredis, until https://github.com/pietern/hiredis-node/pull/33 is resolved
    environment => 'CFLAGS="-std=c99"',
    command     => 'npm install -d',
    logoutput   => 'on_failure',
    require     => [ File[$app_root_dir], Package[$packages], Vcsrepo[$app_root_dir], Exec['npm_reinstall_nodegyp'] ],
  }

  # chown the application root to the app user
  exec { 'app_root_dir_chown':
    cwd         => $app_root_dir,
    command     => "chown -R $os_user:$os_group .",
    logoutput   => "on_failure",
    require     => [ Exec["npm_install_dependencies"] ],
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
    mode    => "0644",
    owner   => $os_user,
    group   => $os_group,
    content => template('hilary/config.js.erb'),
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
        content =>  template('hilary/upstart_hilary.conf.erb'),
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
    solaris, Solaris: {
      # Daemon script needed for SMF to manage the application
      file { "${app_root_dir}/service.xml":
        ensure  =>  present,
        content =>  template('hilary/node-oae-service-manifest.xml.erb'),
        notify  =>  Exec["svccfg_${service_name}"],
        require =>  Vcsrepo[$app_root_dir],
      }

      # Force reload the manifest
      exec { "svccfg_${service_name}":
        command   => "/usr/sbin/svccfg import ${app_root_dir}/service.xml",
        require   => File["${app_root_dir}/service.xml"],
      }

      # Start the app server
      service { $service_name:
        ensure   => running,
        manifest => "${app_root_dir}/service.xml",
        require  => [ Exec["svccfg_${service_name}"], Vcsrepo[$ux_root_dir], Exec["npm_install_dependencies"], ]
      }
    }
    default: {
      exec { "notsupported":
        command   => fail("No support yet for ${::operatingsystem}")
      }
    }
  }
}
