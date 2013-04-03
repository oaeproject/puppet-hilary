class oaeservice::deps::common {

  case $operatingsystem {
    debian, ubuntu: {
      package { 'build-essential': ensure => present }
      package { 'automake': ensure => present }
    }
    solaris, Solaris: {
      package { 'gcc47': ensure => present, provider => 'pkgin' }
      package { 'automake': ensure => present, provider => 'pkgin' }
      package { 'gmake': ensure => present, provider => 'pkgin' }
    }
    default: {
      package { 'gcc': ensure => present }
      package { 'automake': ensure => present }
      package { 'gmake': ensure => present }
    }
  }

  include ::oaeservice::deps::package::git
}