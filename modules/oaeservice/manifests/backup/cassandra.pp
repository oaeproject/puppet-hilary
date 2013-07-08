class oaeservice::backup::cassandra {

    $db_data_dir = hiera('db_data_dir')

    # Other param values come from duplicity::params
    duplicity { 'cassandra':
        directory   => $db_data_dir,
        folder      => $::hostname
    }

}