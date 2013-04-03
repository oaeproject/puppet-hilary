class oaeservice::etherpad {
  require oaeservice::deps::common
  require oaeservice::deps::package::nodejs
  
  Class['::oaeservice::deps::common']           -> Class['::etherpad']
  Class['::oaeservice::deps::package::git']     -> Class['::etherpad']
  Class['::oaeservice::deps::package::nodejs']  -> Class['::etherpad']

  $index = hiera('nodesuffix')

  class { '::etherpad':
    listen_address  => hiera('etherpad_hosts')[$index],
    api_key         => hiera('etherpad_api_key')
  }
}