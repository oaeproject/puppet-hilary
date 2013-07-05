class oaeservice::etherpad {
  include oaeservice::deps::common
  include oaeservice::deps::package::nodejs
  include oaeservice::deps::ppa::oae

  Class['::oaeservice::deps::common']           -> Class['::etherpad']
  Class['::oaeservice::deps::package::git']     -> Class['::etherpad']
  Class['::oaeservice::deps::package::nodejs']  -> Class['::etherpad']
  Class['::oaeservice::deps::ppa::oae']         -> Class['::etherpad']

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

    install_method          => hiera('etherpad_install_method', 'git'),
    apt_package_version     => hiera('etherpad_apt_package_version', 'latest'),
    etherpad_git_source     => hiera('etherpad_git_source', 'https://github.com/ether/etherpad-lite'),
    etherpad_git_revision   => hiera('etherpad_git_revision', 'develop'),
    ep_oae_git_source       => hiera('etherpad_ep_oae_git_source'),
    ep_oae_git_revision     => hiera('etherpad_ep_oae_git_revision'),

    enable_abiword          => hiera('etherpad_enable_abiword'),
  }
}
