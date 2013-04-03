class oaeservice::deps::package::graphicsmagick {
  case $operatingsystem {
    debian, ubuntu: {
      package { 'graphicsmagick': ensure => present }
    }
    solaris, Solaris: {
      package { 'GraphicsMagick': ensure => present, provider => 'pkgin' }
    }
    default: {
      package { 'GraphicsMagick': ensure => present }
    }
  }
}