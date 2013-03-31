class oaeservice::munin::client {
  $nodetype = hiera('nodetype')
  $nodesuffix = hiera('nodesuffix')
  
  class { '::munin::client': hostname => "${nodetype}${suffix}" }
}