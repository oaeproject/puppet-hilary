class nginx(
    $internal_app_ips,
    $ux_home    = '/opt/3akai-ux',
    $files_home = '/opt/files',
    $owner      = 'www',
    $group      = 'www') {

  package { 'nginx':
    ensure    => present,
    provider  => pkgin,
  }
  
  file { '/opt/local/etc/nginx/nginx.conf':
    path    => '/opt/local/etc/nginx/nginx.conf', 
    ensure  => present,
    mode    => 0640,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx.conf.erb'),
    require => Package['nginx'],
    notify  => Service['nginx'],
  }
  
  service { 'nginx':
    ensure  => running,
    enable  => 'true',
    require => Package['nginx'],
  }

}