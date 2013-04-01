class oaeservice::hilary {

  $rsyslog_enabled = hiera('rsyslog_enabled', false)
  if $rsyslog_enabled {
    $rsyslog_host = hiera('rsyslog_host')
  } else {
    $rsyslog_host = false
  }

  $activitycache_enabled = hiera('activitycache_enabled', false)
  if $activitycache_enabled {
    $activitycache_host_master = hiera('activitycache_host_master', false)
    $activitycache_host_slave = hiera('activitycache_host_slave')
  } else {
    $activitycache_host_master = false
    $activitycache_host_slave = false
  }

  class { '::hilary':
    app_root_dir                  => hiera('app_root_dir'),
    app_git_user                  => hiera('app_git_user'),
    app_git_branch                => hiera('app_git_branch'),
    ux_root_dir                   => hiera('ux_root_dir'),
    ux_git_user                   => hiera('ux_git_user'),
    ux_git_branch                 => hiera('ux_git_branch'),
    os_user                       => hiera('app_os_user'),
    os_group                      => hiera('app_os_user'),
    upload_files_dir              => hiera('app_files_dir'),
    config_cassandra_hosts        => hiera('db_hosts'),
    config_redis_host_master      => hiera('cache_host_master'),
    config_search_hosts           => hiera('search_hosts'),
    config_mq_host                => hiera('mq_host_master'),
    config_etherpad_hosts         => hiera('etherpad_hosts'),
    config_etherpad_api_key       => hiera('etherpad_api_key'),
    config_etherpad_domain_suffix => hiera('etherpad_domain_suffix'),
    config_log_syslog_ip          => $rsyslog_host,
    config_activity_redis_host    => $activitycache_host_master,
    config_signing_key            => hiera('app_signing_key')
  }
}