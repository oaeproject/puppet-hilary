class opscenter(
    $listen_address = '0.0.0.0',
    $port = 8888) {

  package { 'opscenter-free':
    ensure  => installed,
  }
  
  file { '/etc/opscenter/opscenterd.conf':
    ensure  => present,
    content => template('opscenter/opscenterd.conf.erb'),
    require => Package['opscenter-free'],
    notify  => Service['opscenterd'],
  }
  
  service { 'opscenterd':
    ensure  => 'running',
    enable  => 'true',
    require => Package['opscenter-free'],
  }
  
}