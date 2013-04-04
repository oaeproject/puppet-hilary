class oaeservice::deps::pp {
  include oaeservice::deps::common

  $phantomjs_version = hiera('phantomjs_version')
  $phantomjs_checksum = hiera('phantomjs_checksum')

  # Necessary packages for phantomjs and other PP functionality
  $pp_packages = [ 'libreoffice', 'pdftk', 'chrpath', 'libssl-dev', 'libfontconfig1-dev' ]
  package { $pp_packages: ensure => installed }

  archive { 'phantomjs':
    ensure        => present,
    url           => "https://phantomjs.googlecode.com/files/phantomjs-${phantomjs_version}-linux-x86_64.tar.bz2",
    digest_string => $phantomjs_checksum,
    target        => '/opt',
    extension     => 'tar.bz2',
    src_target    => '/opt',
    require       => [ Package[$pp_packages], Class['::oaeservice::deps::common'] ]
  }

}