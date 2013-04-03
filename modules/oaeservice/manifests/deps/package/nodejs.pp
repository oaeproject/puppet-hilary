class oaeservice::deps::package::nodejs {

  $nodejs_version = '0.8.22'
  $npm_version = '1.2.14'
  $nodegyp_version = '0.9.3'

  # Crazy exact apt versioning
  $nodejs_ubuntu_version = "${nodejs_version}-1chl1~precise1"
  $npm_ubuntu_version = "${npm_version}-1chl1~precise1"

  case $operatingsystem {
    debian, ubuntu: {
      $npm_dir = '/usr/lib/nodejs/npm'
      $npm_require = "npm=$npm_ubuntu_version"

      # Apply apt configuration, which should be executed before these packages are installed
      include apt
      apt::key { 'chris-lea': key => '4BD6EC30' }
      apt::ppa { 'ppa:chris-lea/node.js': }
      apt::ppa { 'ppa:chris-lea/node.js-legacy': }

      package { "nodejs=$nodejs_ubuntu_version": ensure => installed, require => Class['apt'] }
      package { "npm=$npm_ubuntu_version": ensure => installed, require => Class['apt'] }
    }
    solaris, Solaris: {
      $npm_dir = '/opt/local/lib/node_modules/npm'
      $npm_require = "nodejs-$node_version"

      ## npm installs by default in the pkgin repos
      package { "nodejs-$node_version": ensure => installed, provider => 'pkgin' }
    }
    default: {
      $npm_dir = '/usr/lib/nodejs/npm'
      $npm_require = "npm-$npm_version"

      package { "nodejs-$node_version": ensure => installed }
      package { "npm-$npm_version": ensure => installed }
    }
  }

  # Force the npm bundled version of node-gyp to upgrade node-gyp. Needed to build node-expat and hiredis
  exec { 'npm_reinstall_nodegyp':
    command   => "npm install node-gyp@$nodegyp_version",
    cwd       => $npm_dir,
    logoutput => 'on_failure',
    require   => Package[$npm_require],
  }
}