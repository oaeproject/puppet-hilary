class localconfig::ordering::app {
  # Get the files mounted before we tackle the app server
  Class['::oaeservice::hilary::files'] -> Class['::hilary']
}