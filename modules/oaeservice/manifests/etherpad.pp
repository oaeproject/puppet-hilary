class oaeservice::etherpad {
  require oaeservice::deps::common
  require oaeservice::deps::package::nodejs
  
  Class['::oaeservice::deps::common']           -> Class['::etherpad']
  Class['::oaeservice::deps::package::git']     -> Class['::etherpad']
  Class['::oaeservice::deps::package::nodejs']  -> Class['::etherpad']

  $index = hiera('etherpad_index', 0)
  $hosts = hiera('etherpad_internal_hosts')

  class { '::etherpad':
    listen_address        => $hosts[$index],
    session_key           => hiera('etherpad_session_key'),
    api_key               => hiera('etherpad_api_key'),
    oae_db_hosts          => hiera('db_hosts'),
    oae_db_keyspace       => hiera('db_keyspace'),
    oae_db_replication    => hiera('db_replication_factor'),
    oae_db_strategy_class => hiera('db_strategy_class'),
    oae_sign_key          => hiera('app_signing_key'),
  }
}
