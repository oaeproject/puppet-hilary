class hilary (
    $app_root_dir,

    # Whether to install Hilary from a GitHub repo (with $app_git_user and $app_git_branch) or
    # to pull it as a package.
    # If you're pulling down Hilary as a package, it's assumed you've already setup
    # the PPA / Apt repository where it should be pulled from.
    # Valid options are 'git' and 'apt'
    $install_method  = 'git',
    $apt_package_version = '0.2.0-1',
    $git_source,
    $git_revision,
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

  case $install_method {
        'git': {
            class { '::hilary::install::git':
                app_root_dir        => $app_root_dir,
                git_source          => $git_source,
                git_revision        => $git_revision,
            }
        }
        'apt': {
            class { '::hilary::install::apt':
                package_version     => $package_version,
            }
        }
        default: {
            warning("Unknown install method for hilary passed in: '${install_method}'")
        }
  }

  Class["::hilary::install::${install_method}"] -> File["/etc/init/hilary.conf"]
  Class["::hilary::install::${install_method}"] -> File["${app_root_dir}/config.js"]

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
      require => [ File[$upload_files_dir], File[$config_files_tmp_dir], File[$config_files_tmp_upload_dir] ]
  }



  #######################
  ## START APPLICATION ##
  #######################

  file { "/etc/init/hilary.conf":
    ensure  =>  present,
    content =>  template('hilary/upstart_hilary.conf.erb'),
  }

  service { 'hilary':
    ensure   => running,
    provider => 'upstart',
    require  => File['/etc/init/hilary.conf']
  }

}
