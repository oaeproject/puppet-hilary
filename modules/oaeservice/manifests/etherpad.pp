class oaeservice::etherpad {
  include oaeservice::deps::common
  include oaeservice::deps::package::etherpadnodejs
  include oaeservice::deps::ppa::oae

  Class['::oaeservice::deps::common']           -> Class['::etherpad']
  Class['::oaeservice::deps::package::etherpadnodejs']  -> Class['::etherpad']
  Class['::oaeservice::deps::ppa::oae']         -> Class['::etherpad']

  $index = hiera('etherpad_index', 0)
  $hosts = hiera('etherpad_internal_hosts')

  $install_method = hiera('etherpad_install_method', 'archive')
  $install_config = hiera('etherpad_install_config', {
    'url_base'              => 'https://s3-eu-west-1.amazonaws.com/oae-releases/etherpad',
    'version_major_minor'   => '1.2',
    'version_patch'         => '91',
    'version_nodejs'        => '0.10.17',
  })

  class { '::etherpad':
    listen_address        => $hosts[$index],
    session_key           => hiera('etherpad_session_key'),
    api_key               => hiera('etherpad_api_key'),

    oae_db_hosts          => hiera('db_hosts'),
    oae_db_keyspace       => hiera('db_keyspace'),
    oae_db_replication    => hiera('db_replication_factor'),
    oae_db_strategy_class => hiera('db_strategy_class'),

    oae_mq_hosts          => hiera('mq_hosts'),

    install_method        => $install_method,
    install_config        => $install_config,

    enable_abiword        => hiera('etherpad_enable_abiword')
  }
}
