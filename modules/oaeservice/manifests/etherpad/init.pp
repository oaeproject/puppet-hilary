class oaeservice::etherpad {
  $index = hiera('nodesuffix')

  class { '::etherpad':
    listen_address  => hiera('etherpad_hosts')[$index],
    api_key         => hiera('etherpad_api_key')
  }
}