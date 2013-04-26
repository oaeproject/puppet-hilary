# Configuration class for the munin-master

class munin::master (
    $http_username = 'munin',
    $http_password = '$apr1$mHbJ.NUW$tjkx9vxw6Ga.LMZkMFuJd0',
    $data_directory = '/data/munin'
  ) {

  package { 'munin':
    ensure => installed
  }

  file { '/etc/munin/munin.conf':
    ensure  => present,
    content => template('munin/munin.conf.erb'),
    require => Package['munin'],
  }

  file { $data_directory:
    ensure  => directory,
    owner   => 'munin',
    group   => 'munin',
    require => Package['munin'],
  }

  # Collect all the munin host files
  Package['munin'] -> File <<| tag == 'munin' |>>

  # Configure Apache2 to host munin.
  # This assumes Apache2 is present.
  file { '/etc/apache2/sites-enabled/000-munin':
    ensure  => present,
    content => template('munin/000-munin'),
    notify  => Service['apache2'],
    require => Package['munin'],
  }

  file { '/etc/munin/htpasswd.users':
    ensure  => present,
    content => "$http_username:$http_password",
    require => Package['munin'],
  }

}
