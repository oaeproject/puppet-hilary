class oaeservice::hilary {
  require oaeservice::deps::common
  require oaeservice::deps::package::git
  require oaeservice::deps::package::nodejs
  require oaeservice::deps::package::graphicsmagick

  Class['::oaeservice::deps::common']                   -> Class['::hilary']
  Class['::oaeservice::deps::package::git']             -> Class['::hilary']
  Class['::oaeservice::deps::package::nodejs']          -> Class['::hilary']
  Class['::oaeservice::deps::package::graphicsmagick']  -> Class['::hilary']

  $rsyslog_enabled = hiera('rsyslog_enabled', false)
  if $rsyslog_enabled {
    $rsyslog_host = hieraptr('rsyslog_host')
  } else {
    $rsyslog_host = false
  }

  $activitycache_enabled = hiera('activitycache_enabled', false)
  if $activitycache_enabled {
    $activitycache_host_master = hieraptr('activitycache_host_master')
    $activitycache_host_slave = hieraptr('activitycache_host_slave', undef)
  } else {
    $activitycache_host_master = false
    $activitycache_host_slave = false
  }

  $phantomjs_version = hiera('phantomjs_version')

  class { '::hilary':
    app_root_dir                  => hiera('app_root_dir'),
    app_git_user                  => hiera('app_git_user'),
    app_git_branch                => hiera('app_git_branch'),
    ux_root_dir                   => hiera('ux_root_dir'),
    os_user                       => hiera('app_os_user'),
    os_group                      => hiera('app_os_group'),
    upload_files_dir              => hiera('app_files_dir'),

    config_cookie_secret          => hiera('app_cookie_secret'),
    config_signing_key            => hiera('app_signing_key'),
    config_telemetry_circonus_url => hiera('circonus_url'),
    config_servers_admin_host     => hiera('app_admin_host'),

    config_cassandra_hosts          => map_hieraptr('db_hosts'),
    config_cassandra_keyspace       => hiera('db_keyspace'),
    config_cassandra_timeout        => hiera('db_timeout'),
    config_cassandra_replication    => hiera('db_replication_factor'),
    config_cassandra_strategy_class => hiera('db_strategy_class'),

    config_redis_host_master          => hieraptr('cache_host_master'),
    config_search_hosts               => map_hieraptr('search_hosts'),
    config_mq_host                    => hieraptr('mq_host_master'),
    config_etherpad_hosts             => map_hieraptr('etherpad_hosts'),
    config_etherpad_api_key           => hiera('etherpad_api_key'),
    config_etherpad_domain_suffix     => hiera('etherpad_domain_suffix'),
    config_log_syslog_ip              => $rsyslog_host,
    config_activity_redis_host        => $activitycache_host_master,
    config_previews_phantomjs_binary  => "/opt/phantomjs-${phantomjs_version}-linux-x86_64/bin/phantomjs"
  }
}