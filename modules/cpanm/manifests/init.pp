class cpanm {

  # Copy the cpan installation script.
  file { '/root/cpanm.pl':
    ensure  => present,
    content => template('cpanm/cpanm.pl'),
  }

  # Run the installer if cpanm is not installed.
  exec { 'install_cpanm':
    unless  => 'test -f /usr/local/bin/cpanm',
    command => '/usr/bin/perl /root/cpanm.pl --self-upgrade',
    require => File['/root/cpanm.pl'],
  }
}
