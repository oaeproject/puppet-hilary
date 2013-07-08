class oaeservice::backup::userfiles {

    require nfs::client
    require oaeservice::hilary::files

    $user_files_dir_parent = hiera('app_files_parent')

    # Other param values come from duplicity::params
    duplicity { 'userfiles': directory => $user_files_dir_parent }
}