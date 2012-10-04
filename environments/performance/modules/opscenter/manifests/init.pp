class opscenter($listen_address, $port = 8888) {

  package { 'opscenter-free':
    ensure  => installed,
  }
  
  file { '/etc/opscenter/opscenterd.conf':
    ensure  => present,
    content => template('opscenter/opscenterd.conf.erb'),
    requires => Package['opscenter-free'],
    notify => Service['opscenterd'],
  }
  
  service { 'opscenterd':
    ensure  => 'running',
    enable  => 'true',
    require => Package['opscenter-free'],
  }
  
}