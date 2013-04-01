class oaeservice::hilary::pp {

  # Necessary packages for phantomjs and other PP functionality
  $pp_packages = [ 'libreoffice', 'pdftk', 'chrpath', 'libssl-dev', 'libfontconfig1-dev' ]

  package { $pp_packages: ensure => installed }

  # Checkout a deterministic tip of the 1.9 phantomjs branch. Cannot use vcsrepo as we need 'unless' functionality
  exec { 'clone_phantomjs':
    cwd     => '/tmp',
    command => 'git clone https://github.com/ariya/phantomjs.git',
    creates => '/tmp/phantomjs',
    unless  => 'test -x /usr/bin/phantomjs',
    require => Package['git'],
  }

  exec { 'checkout_phantomjs':
    cwd     => '/tmp/phantomjs',
    command => 'git reset --hard da71c5fbddafbef5c033fd6cd4a916ab3c9fd548',
    unless  => 'test -x /usr/bin/phantomjs',
    require => Exec['clone_phantomjs'],
  }

  exec { '/tmp/phantomjs/build.sh':
    cwd         => '/tmp/phantomjs',
    command     => 'bash build.sh',
    unless      => 'test -x /usr/bin/phantomjs',
    require     => [ Package[$pp_packages], Package['build-essential'], Package['git'], Exec['checkout_phantomjs'] ],
    before      => Service['hilary'],
  }

  include oaeservice::hilary
}