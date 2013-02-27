class nginx(
    $internal_app_ips,
    $ux_home        = '/opt/3akai-ux',
    $ux_admin_host  = 'admin.oae-performance.sakaiproject.org',
    $files_home     = '/opt/files',
    $cert           = '/opt/local/etc/nginx/server.crt',
    $cert_key       = '/opt/local/etc/nginx/server.key',
    $owner          = 'www',
    $group          = 'www') {

  file { 'nginx_script':
    path    => '/home/admin/nginx/scripts/install.sh',
    ensure  => present,
    mode    => 0700,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nginx/scripts/install.sh',
  }

  exec { 'nginx_install':
    cwd       => '/tmp',
    command   => '/home/admin/nginx/scripts/install.sh',
    require   => File['nginx_script']
  }
  
  file { 'nginx_config':
    path    => '/opt/local/etc/nginx/nginx.conf', 
    ensure  => present,
    mode    => 0640,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx.conf.erb'),
    require => Exec['nginx_install'],
    notify  => Service['nginx'],
  }
  
  service { 'nginx':
    ensure  => running,
    enable  => 'true',
    require => File['nginx_config'],
  }

}
