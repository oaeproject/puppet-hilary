class localconfig::nfsmigration {
    $user_files_tmp_nfs_server = "monitor"
    $user_files_tmp_nfs_source_dir = "/data/sakai-useruploads"
    $user_files_tmp_dir_parent = "/sharedmonitor"

    require nfs::client
    nfs::mount { $user_files_tmp_dir_parent:
        ensure      => present,
        mountpoint  => $user_files_tmp_dir_parent,
        server      => $user_files_tmp_nfs_server,
        share       => $user_files_tmp_nfs_source_dir,
    }
}
