class rsyslog (
    $clientOrServer   = 'client',
    $server_host      = '127.0.0.1',
    $server_logdir    = '/var/log/rsyslog',
    $owner            = 'root',
    $group            = 'root',
  ) {

  case $operatingsystem {
    debian, ubuntu: {
      $provider = 'apt'
    }
    solaris, Solaris: {
      $provider = 'pkgin'
    }
    default: {
      $provider = 'yum'
    }
  }

  package { 'rsyslog':
    ensure => installed,
    provider => $provider
  }

  case $operatingsystem {
    solaris, Solaris: {
      # For SmartOS, we'll need to ensure that the default syslogd is disabled
      service { 'system/system-log':
        ensure => disabled,
        before => Service['rsyslog'],
      }
    }
  }

  file { '/etc/rsyslog.conf':
    notify  => Service['rsyslog'],
    owner   => $owner,
    group   => $group,
    content => template("rsyslog/rsyslog.${clientOrServer}.conf.erb"),
  }

  service { 'rsyslog': 
    ensure  => running,
    require => File['/etc/rsyslog.conf'],
  }
}