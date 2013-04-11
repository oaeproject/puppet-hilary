class oaeservice::hilary::files {
  $hilary_files = hiera('app_files_nfs')
  $app_files_parent = hiera('app_files_parent')

  require nfs::client
  nfs::mount { $app_files_parent:
    ensure      => present,
    mountpoint  => $app_files_parent,
    server      => $hilary_files['server'],
    share       => $hilary_files['source_dir'],
  }
}