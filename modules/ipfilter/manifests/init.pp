class elasticsearch ($rules = 'null') {

  file { '/etc/ipf/ipf.conf':
    notify  => Service['ipfilter'],
    ensure  => present,
    mode    => '0600',
    content => template('ipfilter/ipf.conf.erb'),
  }

  service { 'ipfilter':
    ensure  => 'running',
    enable  => true,
    require => File['/etc/ipf/ipf.conf'],
  }
}