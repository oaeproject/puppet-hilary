class localconfig::ordering::tsung {
  # Install common deps (specifically, autoconf and automake) before trying to compile tsung
  Class['::oaeservice::deps::common']   -> Class['::tsung::install::git']
}
