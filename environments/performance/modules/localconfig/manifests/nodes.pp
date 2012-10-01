node 'app0' inherits appnode {
  
  package { 'gcc-compiler':
    ensure   => present,
    provider => pkgin,
  }
  
  $node_version = $localconfig::node_version
  $node_dl = "/tmp/node-v$node_version.tar.gz"
  $node_dir = "/opt/node/${localconfig::node_version}"
  
  exec { 'node_wget':
    command => "/usr/bin/wget http://nodejs.org/dist/v${node_version}/node-v${node_version}.tar.gz -O $node_dl",
    unless  => "test -f $node_dir"
  }
}