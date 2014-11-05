#
# Valid options for install_method and install_config are enumerated in ::hilary::install namespace documentation
#
class hilary (
    $app_root_dir,

    $install_method     = 'git',
    $install_config     = {'source' => 'https://github.com/oaeproject/Hilary', 'revision' => 'master'},

    $os_user,
    $os_group,
    $upload_files_dir,

    ############
    ## Config ##
    ############

    # Files
    $config_files_tmp_dir             = '/tmp',

    # UI
    $config_ui_path                   = '/opt/3akai-ux',

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
    $config_servers_shib_host,
    $config_servers_use_https         = true,
    $config_servers_strict_https      = true,
    $config_servers_server_internal_address = '127.0.0.1',

    # Cookie
    $config_cookie_secret,

    # Logging
    $config_log_syslog_ip             = false,

    # Telemetry
    $config_telemetry_circonus_url,

    # Search
    $config_search_hosts,
    $config_search_enabled            = true,

    # RabbitMQ
    $config_mq_hosts,

    # Previews
    $config_previews_enabled              = false,
    $config_previews_credentials_username = 'administrator',
    $config_previews_credentials_password = 'administrator',

    # Signing
    $config_signing_key,

    # Activity
    $config_activity_enabled          = false,
    $config_activity_redis_host       = false,
    $config_activity_redis_port       = 6379,

    # Email notifications
    $config_email_debug                      = false,
    $config_email_customEmailTemplatesDir    = 'null',
    $config_email_deduplicationInterval      = 604800,
    $config_email_throttleTimespan           = 120,
    $config_email_throttleCount              = 10,
    $config_email_transport                  = 'sendmail',
    $config_email_sendmail_path              = '/usr/sbin/sendmail',
    $config_email_smtp_service               = 'Gmail',
    $config_email_smtp_user                  = 'user@gmail.com',
    $config_email_smtp_pass                  = 'password',

    # Etherpad
    $config_etherpad_internal_hosts,
    $config_etherpad_api_key,

    # Mixpanel
    $config_mixpanel_enabled          = false,
    $config_mixpanel_token            = '',
    ) {

  $config_files_tmp_upload_dir = "${config_files_tmp_dir}/uploads"
  $config_previews_tmp_dir = "${config_files_tmp_dir}/previews"



  ##################
  ## INSTALLATION ##
  ##################

  class { "::hilary::install::${install_method}":
    install_config  => $install_config,
    app_root_dir    => $app_root_dir,
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



  ###################
  ## CONFIGURATION ##
  ###################

  file { "/etc/init/hilary.conf":
    ensure  =>  present,
    content =>  template('hilary/upstart_hilary.conf.erb'),
  }

  service { 'hilary':
    ensure   => running,
    provider => 'upstart',
    require  => File['/etc/init/hilary.conf', "${app_root_dir}/config.js"]
  }

}
