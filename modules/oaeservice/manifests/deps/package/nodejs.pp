class oaeservice::deps::package::nodejs ($nodejs_version, $npm_version, $nodegyp_version = '0.9.3') {
  include ::oaeservice::deps::ppa::nodejs

  package { 'nodejs':
    ensure  => $nodejs_version
  }

  package { 'nodejs-dev':
    ensure  => $nodejs_version,
    require => [ Package['nodejs'] ]
  }

  package { 'npm':
    ensure  => $npm_version,
    require => [ Package['nodejs-dev'] ],
    notify  => Exec['npm_reinstall_nodegyp'],
  }

  if $npm_version == '1.3.0-1chl1~precise1' {
    ## Workaround to fix issue with semver 2.0.7 where "nmax" semver went to the min, not the max :(
    exec { 'npm_upgrade_semver':
      command     => "npm install semver@2.0.8",
      cwd         => '/usr/lib/nodejs/npm',
      logoutput   => 'on_failure',
      subscribe   => Package['npm'],
      refreshonly => true,
    }
  }

  # Force the npm bundled version of node-gyp to upgrade node-gyp. Needed to build node-expat and hiredis
  exec { 'npm_reinstall_nodegyp':
    command     => "npm install node-gyp@${nodegyp_version}",
    cwd         => '/usr/lib/nodejs/npm',
    logoutput   => 'on_failure',
    subscribe   => Package['npm'],
    refreshonly => true,
  }
}
