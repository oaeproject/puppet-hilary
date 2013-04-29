class oaeservice::etherpad {
  require oaeservice::deps::common
  require oaeservice::deps::package::nodejs
  
  Class['::oaeservice::deps::common']           -> Class['::etherpad']
  Class['::oaeservice::deps::package::git']     -> Class['::etherpad']
  Class['::oaeservice::deps::package::nodejs']  -> Class['::etherpad']

  class { '::etherpad':
    listen_address  => $ipaddress_eth1,
    api_key         => hiera('etherpad_api_key')
  }
}