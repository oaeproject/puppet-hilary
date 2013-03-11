class rsyslog (
    $clientOrServer   = 'client',
    $server_host      = '127.0.0.1',
    $server_logdir    = '/var/log/rsyslog',
    $owner            = 'root',
    $group            = 'root',
    $imfiles           = false,
  ) {

  case $operatingsystem {
    debian, ubuntu: {
      $solaris = false
      $provider = 'apt'
      $configpath = '/etc/rsyslog.conf'
    }
    solaris, Solaris: {
      $solaris = true
      $provider = 'pkgin'
      $configpath = '/opt/local/etc/rsyslog.conf'
    }
    default: {
      $solaris = false
      $provider = 'yum'
      $configpath = '/etc/rsyslog.conf'
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
        ensure => stopped,
        before => Service['rsyslog'],
      }
    }
  }

  file { "${configpath}":
    notify  => Service['rsyslog'],
    owner   => $owner,
    group   => $group,
    content => template("rsyslog/rsyslog.${clientOrServer}.conf.erb"),
  }

  service { 'rsyslog': 
    ensure  => running,
    require => File["${configpath}"],
  }
}