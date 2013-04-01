class oaeservice::hilary::pp {

  # Necessary packages for phantomjs and other PP functionality
  $pp_packages = [ 'libreoffice', 'pdftk', 'chrpath', 'libssl-dev', 'libfontconfig1-dev' ]
  package { $pp_packages: ensure => installed }

  archive { 'phantomjs.tar.bz2':
    ensure      => present,
    url         => 'https://phantomjs.googlecode.com/files/phantomjs-1.9.0-linux-x86_64.tar.bz2',
    target      => '/opt',
  }

  include oaeservice::hilary
}