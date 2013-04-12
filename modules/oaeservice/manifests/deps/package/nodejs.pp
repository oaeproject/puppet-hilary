class oaeservice::deps::package::nodejs ($nodejs_version, $npm_version, $nodegyp_version = '0.9.3') {

  # Apply apt configuration, which should be executed before these packages are installed
  include apt
  apt::key { 'chris-lea': key => '4BD6EC30' }
  apt::ppa { 'ppa:chris-lea/node.js': }
  apt::ppa { 'ppa:chris-lea/node.js-legacy': }

  package { "nodejs=${nodejs_version}": ensure => installed, require => Class['apt'] }
  package { "nodejs-dev=${nodejs_version}": ensure => installed, require => Class['apt'] }
  package { "npm=${npm_version}": ensure => installed, require => Class['apt'] }

  # Force the npm bundled version of node-gyp to upgrade node-gyp. Needed to build node-expat and hiredis
  exec { 'npm_reinstall_nodegyp':
    command   => "npm install node-gyp@${nodegyp_version}",
    cwd       => '/usr/lib/nodejs/npm',
    logoutput => 'on_failure',
    require   => Package["npm=${npm_version}"],
  }
}