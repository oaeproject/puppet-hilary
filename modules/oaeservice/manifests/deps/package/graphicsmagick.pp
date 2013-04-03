class oaeservice::deps::package::graphicsmagick {
  case $operatingsystem {
    debian, ubuntu: {
      package { 'graphicsmagick': ensure => installed }
    }
    solaris, Solaris: {
      package { 'GraphicsMagick': ensure => installed, provider => 'pkgin' }
    }
    default: {
      package { 'GraphicsMagick': ensure => installed }
    }
  }
}