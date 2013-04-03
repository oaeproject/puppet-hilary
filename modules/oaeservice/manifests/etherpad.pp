class oaeservice::etherpad {
  include oaeservice::deps::common
  include oaeservice::deps::package::nodejs
  
  $index = hiera('nodesuffix')

  class { '::etherpad':
    listen_address  => hiera('etherpad_hosts')[$index],
    api_key         => hiera('etherpad_api_key'),
    require         => [ Class['::Oaeservice::Deps::Common'], Class['::Oaeservice::Deps::Package::Nodejs'] ]
  }
}