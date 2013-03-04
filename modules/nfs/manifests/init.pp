class nfs (
    $mountpoint,
    $server,
    $sourcedir) {

  file { $mountpoint:
    ensure => 'directory',
  }

  mount { $mountpoint:
    device      => "${server}:${sourcedir}",
    fstype      => 'nfs',
    ensure      => 'mounted',
    atboot      => 'true',
    options     => 'rw,bg',
    blockdevice => '-',
    require => File[$mountpoint]
  }

  service { 'rpc/bind':
    ensure    => 'running',
    enable    => 'true',
    require   => Mount[$mountpoint],
  }

  service { 'nfs/client':
    ensure    => 'running',
    enable    => 'true',
    require   => Service['rpc/bind'],
  }

  service { 'nfs/status':
    ensure    => 'running',
    enable    => 'true',
    require   => Service['rpc/bind'],
  }

  service { 'nfs/nlockmgr':
    ensure    => 'running',
    enable    => 'true',
    require   => Service['rpc/bind'],
  }

}
