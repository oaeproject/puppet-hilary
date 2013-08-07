class oaeservice::hilary {
  include ::oaeservice::deps::common
  include ::oaeservice::deps::package::git
  include ::oaeservice::deps::package::nodejs
  include ::oaeservice::deps::package::graphicsmagick
  include ::oaeservice::ui

  Class['::oaeservice::deps::common']                   -> Class['::hilary']
  Class['::oaeservice::deps::package::nodejs']          -> Class['::hilary']
  Class['::oaeservice::deps::package::graphicsmagick']  -> Class['::hilary']
  Class['::ui']                                         -> Class['::hilary']

  # If previews are enabled, we also need to include those dependencies
  if (hiera('hilary::config_previews_enabled', false)) {
    include ::oaeservice::deps::pp
    Class['::oaeservice::deps::pp'] -> Class['::hilary']
  }

  $install_method = hiera('app_install_method', 'git')
  $install_config = hiera('app_install_config', {source => 'https://github.com/oaeproject/Hilary', revision => 'master'})

  $rsyslog_enabled = hiera('rsyslog_enabled', false)
  if $rsyslog_enabled {
    $rsyslog_host = hiera('rsyslog_host')
  } else {
    $rsyslog_host = false
  }

  $activitycache_enabled = hiera('activitycache_enabled', false)
  if $activitycache_enabled {
    $activitycache_host = hiera('activitycache_host')
    $activitycache_port = hiera('activitycache_port')
  } else {
    $activitycache_host = false
    $activitycache_port = false
  }

  $email_debug = hiera('email_debug', true)

  $phantomjs_version = hiera('phantomjs_version')

  $web_domain = hiera('web_domain')
  $app_admin_tenant = hiera('app_admin_tenant', 'admin')
  $admin_domain = "${app_admin_tenant}.${web_domain}"

  class { '::hilary':
    app_root_dir                  => hiera('app_root_dir'),

    install_method                => $install_method,
    install_config                => $install_config,

    os_user                       => hiera('app_os_user'),
    os_group                      => hiera('app_os_group'),
    upload_files_dir              => hiera('app_files_dir'),

    config_ui_path                => hiera('app_ui_path', '/opt/3akai-ux'),
    config_cookie_secret          => hiera('app_cookie_secret'),
    config_signing_key            => hiera('app_signing_key'),
    config_telemetry_circonus_url => hiera('circonus_url', false),
    config_servers_admin_host     => $admin_domain,
    config_servers_use_https      => hiera('app_use_https', true),

    config_cassandra_hosts          => hiera('db_hosts'),
    config_cassandra_keyspace       => hiera('db_keyspace'),
    config_cassandra_timeout        => hiera('db_timeout'),
    config_cassandra_replication    => hiera('db_replication_factor'),
    config_cassandra_strategy_class => hiera('db_strategy_class'),

    config_redis_host                 => hiera('cache_host'),
    config_redis_port                 => hiera('cache_port', 6379),
    config_search_hosts               => hiera('search_hosts'),
    config_mq_hosts                   => hiera('mq_hosts'),

    config_etherpad_internal_hosts    => hiera('etherpad_internal_hosts'),
    config_etherpad_api_key           => hiera('etherpad_api_key'),

    config_log_syslog_ip              => $rsyslog_host,
    config_activity_redis_host        => $activitycache_host,
    config_activity_redis_port        => $activitycache_port,

    config_email_debug                      => hiera('email_debug'),
    config_email_customEmailTemplatesDir    => hiera('email_customEmailTemplatesDir'),
    config_email_transport                  => hiera('email_transport'),
    config_email_sendmail_path              => hiera('email_sendmail_path'),
    config_email_smtp_service               => hiera('email_smtp_service'),
    config_email_smtp_user                  => hiera('email_smtp_user'),
    config_email_smtp_pass                  => hiera('email_smtp_pass'),

    config_previews_phantomjs_binary        => "/opt/phantomjs-${phantomjs_version}-linux-x86_64/bin/phantomjs",
    config_previews_credentials_username    => hiera('app_admin_username', 'administrator'),
    config_previews_credentials_password    => hiera('app_admin_password', 'administrator'),

    config_servers_server_internal_address  => hiera('web_internal_address', '127.0.0.1')
  }
}
