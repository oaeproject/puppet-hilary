class hilary (
    $app_root_dir,
    $app_git_user,
    $app_git_branch,
    $ux_root_dir,
    $os_user,
    $os_group,
    $upload_files_dir,

    ############
    ## Config ##
    ############

    # Files
    $config_files_tmp_dir             = '/tmp',

    # Cassandra
    $config_cassandra_hosts,
    $config_cassandra_keyspace        = 'oae',
    $config_cassandra_timeout         = 3000,
    $config_cassandra_replication     = 1,
    $config_cassandra_strategy_class  = 'SimpleStrategy',

    # Redis
    $config_redis_host,
    $config_redis_port                = 6379,

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
    $config_mq_hosts,

    # Previews
    $config_previews_enabled          = false,
    $config_previews_phantomjs_binary = 'phantomjs',

    # Signing
    $config_signing_key,

    # Activity
    $config_activity_enabled          = false,
    $config_activity_redis_host       = false,
    $config_activity_redis_port       = 6379,

    # Email notifications
    $config_email_debug                      = false,
    $config_email_customEmailTemplatesDir    = 'null',
    $config_email_transport                  = 'sendmail',
    $config_email_sendmail_path              = '/usr/sbin/sendmail',
    $config_email_smtp_service               = 'Gmail',
    $config_email_smtp_user                  = 'user@gmail.com',
    $config_email_smtp_pass                  = 'password',

    # Etherpad
    $config_etherpad_internal_hosts,
    $config_etherpad_external_protocol      = 'https',
    $config_etherpad_external_port          = 443,
    $config_etherpad_api_key,
    $config_etherpad_external_domain_suffix) {

  $config_files_tmp_upload_dir = "${config_files_tmp_dir}/uploads"
  $config_previews_tmp_dir = "${config_files_tmp_dir}/previews"


  ########################
  ## DEPLOY APPLICATION ##
  ########################

  # git clone https://github.com/oaeproject/Hilary
  vcsrepo { $app_root_dir:
    ensure    => latest,
    provider  => git,
    source    => "https://github.com/${app_git_user}/Hilary",
    revision  => $app_git_branch
  }

  file { $app_root_dir:
    ensure  => directory,
    mode    => "0644",
    owner   => $os_user,
    group   => $os_group,
    require => Vcsrepo[$app_root_dir],
  }

  # npm install -d
  exec { "npm_install_dependencies":
    cwd         => $app_root_dir,

    # Forcing CFLAGS for std=c99 for hiredis, until https://github.com/pietern/hiredis-node/pull/33 is resolved
    environment => ['CFLAGS="-std=c99"', 'HOME="/root"'],
    command     => 'npm install -d',
    logoutput   => 'on_failure',

    # Exec['npm_reinstall_nodegyp'] is a dependency currently in oaeservice::deps::package::nodejs which ensures nodegyp is the proper version. It's put here because if the dependencies are not assembled properly this failure would be hard to track down
    require     => [ File[$app_root_dir], Vcsrepo[$app_root_dir], Exec['npm_reinstall_nodegyp'] ],
  }

  # chown the application root to the app user
  exec { 'app_root_dir_chown':
    cwd         => $app_root_dir,
    command     => "chown -R $os_user:$os_group .",
    logoutput   => "on_failure",
    require     => [ Exec["npm_install_dependencies"] ],
  }

  # recursively create all tmp directories
  exec { 'mkdir_upload_files_dir': command => "mkdir -p $upload_files_dir" }
  exec { 'mkdir_config_files_tmp_dir': command => "mkdir -p $config_files_tmp_dir" }
  exec { 'mkdir_config_files_tmp_upload_dir': command => "mkdir -p $config_files_tmp_upload_dir" }
  exec { 'mkdir_config_previews_tmp_dir': command => "mkdir -p $config_previews_tmp_dir" }

  file {

    # User uploaded files
    $upload_files_dir:
      ensure  => directory,
      owner   => $os_user,
      group   => $os_group,
      require => Exec['mkdir_upload_files_dir'];

    # Temp files
    $config_files_tmp_dir:
      ensure  => directory,
      owner   => $os_user,
      group   => $os_group,
      require => Exec['mkdir_config_files_tmp_dir'];
    $config_files_tmp_upload_dir:
      ensure  => directory,
      owner   => $os_user,
      group   => $os_group,
      require => Exec['mkdir_config_files_tmp_upload_dir'];
    $config_previews_tmp_dir:
      ensure  => directory,
      owner   => $os_user,
      group   => $os_group,
      require => Exec['mkdir_config_previews_tmp_dir'];

    # Hilary config file
    "${app_root_dir}/config.js":
      ensure  => present,
      mode    => "0644",
      owner   => $os_user,
      group   => $os_group,
      content => template('hilary/config.js.erb'),
      require => [ Vcsrepo[$app_root_dir], File[$upload_files_dir], File[$config_files_tmp_dir],
          File[$config_files_tmp_upload_dir] ]
  }

  

  #######################
  ## START APPLICATION ##
  #######################

  file { "/etc/init/hilary.conf":
    ensure  =>  present,
    content =>  template('hilary/upstart_hilary.conf.erb'),
    require =>  Vcsrepo[$app_root_dir],
  }

  service { 'hilary':
    ensure   => running,
    provider => 'upstart',
    require  => [File['/etc/init/hilary.conf'], Vcsrepo[$ux_root_dir], Exec["npm_install_dependencies"] ]
  }

}
