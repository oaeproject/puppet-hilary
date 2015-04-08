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

        file { "/usr/local/bin/filter-bunyan":
            content => template('rsyslog/filter-bunyan.erb'),
            owner   => 'root',
            group   => 'root',
            mode    => 0754,
        }

        file { "/usr/local/bin/tail-hilary":
            content => template('rsyslog/tail-hilary.erb'),
            owner   => 'root',
            group   => 'root',
            mode    => 0754,
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

    # We're keeping a copy of the maillogs locally to the node for monitoring purposes
    # We only really need the logs of today, so we can remove older logs
    cron { 'remove_old_mail_logs':
        command => "find /var/log/mail -type f -mtime +1 -name \"*.log\" -exec rm '{}' \;",
        user    => 'root',
        target  => 'root',
        hour    => 2,
        minute  => 0,
    }

    # We need to ensure that the mail logs can be read by the monitor scripts
    file { 'readable_email_logs':
        ensure  =>  'directory',
        path    =>  '/var/log/mail',
        mode    =>  0755,
    }

    service { 'rsyslog':
        ensure  => running,
        require => File['/etc/rsyslog.conf'],
    }
}
