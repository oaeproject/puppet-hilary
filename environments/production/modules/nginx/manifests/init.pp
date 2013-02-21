class nginx(
    $internal_app_ips,
    $ux_home        = '/opt/3akai-ux',
    $ux_admin_host  = 'admin.oae-performance.sakaiproject.org',
    $files_home     = '/opt/files',
    $cert           = '/opt/local/etc/nginx/server.crt',
    $cert_key       = '/opt/local/etc/nginx/server.key',
    $owner          = 'www',
    $group          = 'www') {

  exec { 'nginx_install':
    cwd       => '/tmp',
    command   => '/home/admin/puppet-hilary/environments/performance/modules/nginx/scripts/install.sh'
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