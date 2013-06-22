class oaeservice::deps::ppa::nodejs () {

  # Apply apt configuration, which should be executed before these packages are installed
  include apt
  apt::key { 'chris-lea': key => '4BD6EC30' }
  apt::ppa { 'ppa:chris-lea/node.js': }
  apt::ppa { 'ppa:chris-lea/node.js-legacy': }
}
