define nginx (
    $internal_app_ips,
    $internal_etherpad_ips,
    $ux_home        = '/opt/3akai-ux',
    $ux_admin_host  = 'admin.oae-performance.sakaiproject.org',
    $files_home     = '/opt/files',
    $cert           = 'null',
    $cert_key       = 'null',
    $owner          = 'www',
    $group          = 'www',
    $installer_path = '/home/admin/nginx/scripts') {

  exec { 'installdir':
    command => "/opt/local/gnu/bin/mkdir -p ${installer_path}",
    unless  => "/opt/local/gnu/bin/test -d ${installer_path}",
  }

  file { 'nginx_script':
    path    => '/home/admin/nginx/scripts/install.sh',
    ensure  => present,
    mode    => 0700,
    owner   => root,
    group   => root,
    source  => 'puppet:///modules/nginx/install.sh',
    require => Exec['installdir']
  }

  exec { 'nginx_install':
    cwd       => '/tmp',
    command   => "${installer_path}/install.sh",
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
  }

  service { 'nginx':
    ensure  => running,
    enable  => 'true',
    require => File['nginx_config'],
  }

}
