class oaeservice::hilary::files {
  $hilary_files = hiera('app_files_nfs')

  smartosnfs { hiera('app_files_parent'):
    server     => $hilary_files['server'],
    sourcedir  => $hilary_files['sourcedir']
  }
}