class oaeservice::etherpad {
  require oaeservice::deps::common
  require oaeservice::deps::package::nodejs
  
  $index = hiera('nodesuffix')

  class { '::etherpad':
    listen_address  => hiera('etherpad_hosts')[$index],
    api_key         => hiera('etherpad_api_key')
  }
}