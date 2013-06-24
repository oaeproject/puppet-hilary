class oaeservice::deps::common {

  package { 'build-essential': ensure => installed }
  package { 'automake': ensure => installed }
  package { 'libssl-dev': ensure => installed }

  require ::oaeservice::deps::package::git
}
