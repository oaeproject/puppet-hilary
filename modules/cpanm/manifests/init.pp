class cpanm {

  # Copy the cpan installation script.
  file { '/tmp/cpanm.pl':
    ensure  => present,
    content => template('cpanm/cpanm.pl'),
  }

  # Run the installer if cpanm is not installed.
  exec { 'install_cpanm':
    unless  => 'test -f /usr/local/bin/cpanm',
    command => '/usr/bin/perl /tmp/cpanm.pl --self-upgrade',
    require => File['/tmp/cpanm.pl'],
  }
}
