class rsyslog (
    $clientOrServer   = 'client',
    $server_host      = '127.0.0.1',
    $server_logdir    = '/var/log/rsyslog',
    $owner            = 'root',
    $group            = 'root',
    $imfiles          = false,) {

    package { 'rsyslog': ensure => installed }

    file { $server_logdir:
        ensure  => directory,
        owner   => $owner,
        group   => $group,
    }

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
            require => [ Package['rsyslog'], File[$server_logdir] ],
        }

        # Compress all log files that haven't been modified in over 1 day
        cron { 'compress-logs':
            ensure  => present,
            command => "find ${server_logdir} -type f -mtime +1 -name \"*.log\" -exec bzip2 '{}' \;",
            user    => 'root',
            target  => 'root',
            hour    => 0,
            minute  => 1
        }

    }

    service { 'rsyslog':
        ensure  => running,
        require => File['/etc/rsyslog.conf'],
    }
}