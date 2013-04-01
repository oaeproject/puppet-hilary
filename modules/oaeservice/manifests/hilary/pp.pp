class oaeservice::hilary::pp {

  # Necessary packages for phantomjs and other PP functionality
  $pp_packages = [ 'build-essential', 'git-core', 'libreoffice', 'pdftk', 'chrpath', 'libssl-dev', 'libfontconfig1-dev' ]

  package { $pp_packages: ensure => installed }

  # Checkout the tip of the 1.9 phantomjs branch
  vcsrepo { '/tmp/phantomjs':
    provider    => 'git',
    ensure      => 'present',
    source      => 'https://github.com/ariya/phantomjs.git',
    revision    => 'da71c5fbddafbef5c033fd6cd4a916ab3c9fd548',
    unless      => 'test -x /usr/local/bin/phantomjs'
  }

  exec { '/tmp/phantomjs/build.sh':
    cwd         => '/tmp/phantomjs',
    command     => './build.sh',
    unless      => 'test -x /usr/local/bin/phantomjs',
    require     => [ Package[$pp_packages], Vcsrepo['/tmp/phantomjs'] ],
    before      => Class['::hilary'],
  }

  include oaeservice::hilary
}