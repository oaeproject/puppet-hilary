class oaeservice::deps::common {

  # Apply apt configuration
  include apt
  apt::key { 'stuart-freeman': key => '52340974' }
  apt::key { 'branden-visser': key => 'B77CA805' }
  apt::ppa { 'ppa:oae/deps': }

  package { 'build-essential': ensure => installed }
  package { 'automake': ensure => installed }
  package { 'libssl-dev': ensure => installed }

  require ::oaeservice::deps::package::git
}
