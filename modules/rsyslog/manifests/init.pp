class rsyslog (
    $clientOrServer   = 'client',
    $server_host      = '127.0.0.1',
    $server_logdir    = '/var/log/rsyslog',
    $owner            = 'root',
    $group            = 'root',
    $imfiles          = false,
  ) {

  package { 'rsyslog': ensure => installed }

  file { '/etc/rsyslog.conf':
    owner   => $owner,
    group   => $group,
    content => template("rsyslog/rsyslog.${clientOrServer}.conf.erb"),
  }

  if $clientOrServer == 'server' {
    file { '/etc/crontab':
      content => template('rsyslog/crontab.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => 0644
    }

    file { "${server_logdir}/filter-bunyan":
      content => template('rsyslog/filter-bunyan.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => 0754,
    }
  }

  service { 'rsyslog': 
    ensure  => running,
    require => File['/etc/rsyslog.conf'],
  }
}