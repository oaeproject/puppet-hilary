class oaeservice::backup::log {
    include ::oaeservice::deps::package::python

    # Other param values come from duplicity::params
    duplicity {'log': directory => '/var/log/rsyslog' }
}
