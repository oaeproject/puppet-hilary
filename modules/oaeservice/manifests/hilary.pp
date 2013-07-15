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
  if ($install_method == 'git') {
    # Ensure the git dependencies get installed before the etherpad git installation if specified
    Class['::oaeservice::deps::package::git'] -> Class['::hilary::install::git']
  }

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

  $email_debug = hiera('email_debug')

  $phantomjs_version = hiera('phantomjs_version')

  $web_domain = hiera('web_domain')
  $app_admin_tenant = hiera('app_admin_tenant')
  $admin_domain = "${app_admin_tenant}.${web_domain}"

  class { '::hilary':
    app_root_dir                  => hiera('app_root_dir'),

    install_method                => $install_method,

    apt_package_version           => hiera('app_apt_package_version', 'present'),

    archive_source_parent         => hiera('app_archive_source_parent', undef),
    archive_source_filename       => hiera('app_archive_source_filename', undef),
    archive_source_extension      => hiera('app_archive_source_extension', undef),
    archive_checksum              => hiera('app_archive_checksum', undef),

    git_source                    => hiera('app_git_source', 'https://github.com/oaeproject/Hilary'),
    git_revision                  => hiera('app_git_revision', 'master'),

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

    config_previews_phantomjs_binary  => "/opt/phantomjs-${phantomjs_version}-linux-x86_64/bin/phantomjs",
  }
}
