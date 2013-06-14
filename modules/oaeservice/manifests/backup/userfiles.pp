class oaeservice::backup::userfiles {
    require nfs::client

    $backup_hostname = $::hostname

    ####################
    # MOUNT USER FILES #
    ####################

    $user_files_nfs = hiera('app_files_nfs')
    $user_files_dir_parent = hiera('app_files_parent')

    nfs::mount { $user_files_dir_parent:
        ensure      => present,
        mountpoint  => $user_files_dir_parent,
        server      => $user_files_nfs['server'],
        share       => $user_files_nfs['source_dir'],
    }


    #######################
    # MOUNT BACKUP VOLUME #
    #######################

    $user_files_backup_nfs = hiera('app_files_backup_nfs')
    $user_files_backup_dir = hiera('app_files_backup_dir')

    $user_files_backup_script_dir = "/opt/user-files-backup-script"
    $user_files_backup_script_path = "${user_files_backup_script_dir}/backup.sh"
    $user_files_backup_cron_path = "${user_files_backup_script_dir}/backup-cron.sh"

    nfs::mount { $user_files_backup_dir:
        ensure      => present,
        mountpoint  => $user_files_backup_dir,
        server      => $user_files_backup_nfs['server'],
        share       => $user_files_backup_nfs['source_dir'],
    }


    ########################
    # PLACE BACKUP SCRIPTS #
    ########################

    file { $user_files_backup_script_dir: ensure => directory }
    file { $user_files_backup_script_path:
        ensure      => file,
        mode        => 0744,
        content     => template('oaeservice/backup/userfiles/backup.sh.erb'),
        require     => File[$user_files_backup_script_dir],
    }

    file { $user_files_backup_cron_path:
        ensure      => file,
        mode        => 0744,
        content     => template('oaeservice/backup/userfiles/backup-cron.sh.erb'),
        require     => File[$user_files_backup_script_dir],
    }


    ####################
    # SCHEDULE BACKUPS #
    ####################

    cron { 'nightly-userfiles-backup':
        ensure  => present,
        command => "$user_files_backup_cron_path >> /var/log/nightly-userfiles-backup.log 2>> /var/log/nightly-userfiles-backup.log",
        user    => 'root',
        target  => 'root',
        hour    => 4,
        minute  => 0
    }

}