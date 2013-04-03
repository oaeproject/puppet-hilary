class oaeservice::deps::common {

  case $operatingsystem {
    debian, ubuntu: {
      package { 'build-essential': ensure => installed }
      package { 'automake': ensure => installed }
    }
    solaris, Solaris: {
      package { 'gcc47': ensure => installed, provider => 'pkgin' }
      package { 'automake': ensure => installed, provider => 'pkgin' }
      package { 'gmake': ensure => installed, provider => 'pkgin' }
    }
    default: {
      package { 'gcc': ensure => installed }
      package { 'automake': ensure => installed }
      package { 'gmake': ensure => installed }
    }
  }

  require ::oaeservice::deps::package::git
}