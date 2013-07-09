class oaeservice::cassandra::dse {
    include ::oaeservice::deps::package::oraclejava6jre
    include ::oaeservice::cassandra::params

    Class['::oracle-java'] -> Class['::dse::cassandra']

    class { '::dse::cassandra':
        owner               => $::oaeservice::cassandra::params::owner,
        group               => $::oaeservice::cassandra::params::group,
        cluster_name        => $::oaeservice::cassandra::params::cluster_name,
        initial_token       => $::oaeservice::cassandra::params::initial_token,
        listen_address      => $::oaeservice::cassandra::params::listen_address,
        cassandra_data_dir  => $::oaeservice::cassandra::params::data_dir,
        hosts               => $::oaeservice::cassandra::params::hosts,
        rsyslog_enabled     => $::oaeservice::cassandra::params::rsyslog_enabled,
        rsyslog_host        => $::oaeservice::cassandra::params::rsyslog_host,
    }
}