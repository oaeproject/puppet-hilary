class oaeservice::hilary::files {
  $hilary_files = hiera('app_files_nfs')
  $app_files_parent = hiera('app_files_parent')

  smartosnfs { $app_files_parent:
    server     => $hilary_files['server'],
    sourcedir  => $hilary_files['sourcedir']
  }
}