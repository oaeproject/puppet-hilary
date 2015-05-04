class oaeservice::hilary::files {
  $user_files_nfs = hiera('app_files_nfs')
  $user_files_dir_parent = hiera('app_files_parent')

  #require nfs::client
  #nfs::mount { $user_files_dir_parent:
  #  ensure      => present,
  #  mountpoint  => $user_files_dir_parent,
  #  server      => $user_files_nfs['server'],
  #  share       => $user_files_nfs['source_dir'],
  #}
}
