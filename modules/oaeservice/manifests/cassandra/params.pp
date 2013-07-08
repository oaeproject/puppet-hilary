class oaeservice::cassandra::params {
    $owner              = hiera('db_os_user')
    $group              = hiera('db_os_group')
    $cluster_name       = hiera('db_cluster_name')
    $hosts              = hiera('db_hosts')
    $tokens             = hiera('db_tokens')
    $index              = hiera('db_index', 0)
    $initial_token      = $tokens[$index]
    $listen_address     = $hosts[$index]
    $data_dir           = hiera('db_data_dir')
    $rsyslog_enabled    = hiera('rsyslog_enabled', false)
    $rsyslog_host       = $rsyslog_enabled ? { true => hiera('rsyslog_host'), false => false }
}