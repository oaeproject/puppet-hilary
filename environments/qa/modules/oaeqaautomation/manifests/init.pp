class oaeqaautomation ($log_file_path = '/var/log/nightly.log') {

    $backup_dir = hiera('automation_backup_dir')
    $scripts_dir = hiera('automation_scripts_dir')
    $cassandra_data_dir = hiera('db_data_dir')
    $elasticsearch_data_dir = hiera('search_data_dir')
    $user_files_dir = hiera('app_files_dir')
    $app_root_dir = hiera('app_root_dir')
    $ux_root_dir = hiera('ux_root_dir')

    $web_domain = hiera('web_domain')
    $app_admin_tenant = hiera('app_admin_tenant')
    $admin_host = "${app_admin_tenant}.${web_domain}"

    exec { 'mkdir_scripts': command => "mkdir -p ${scripts_dir}", unless => "test -d ${scripts_dir}" }

    file { 'deletedata.sh':
        path => "${scripts_dir}/deletedata.sh",
        mode => 0755,
        content => template('oaeqaautomation/deletedata.sh.erb')
    }

    file { 'nightly.sh':
        path => "${scripts_dir}/nightly.sh",
        mode => 0755,
        content => template('oaeqaautomation/nightly.sh.erb'),
        require => Exec['mkdir_scripts']
    }

    file { 'restoredata.sh':
        path => "${scripts_dir}/restoredata.sh",
        mode => 0755,
        content => template('oaeqaautomation/restoredata.sh.erb'),
        require => Exec['mkdir_scripts']
    }

    file { 'shutdown.sh':
        path => "${scripts_dir}/shutdown.sh",
        mode => 0755,
        content => template('oaeqaautomation/shutdown.sh.erb'),
        require => Exec['mkdir_scripts']
    }

    cron { 'nightly-backup':
        ensure  => present,
        command => "${scripts_dir}/nightly.sh >> ${log_file_path} 2>> ${log_file_path}",
        user    => 'root',
        target  => 'root',
        hour    => 4,
        minute  => 0
    }
}