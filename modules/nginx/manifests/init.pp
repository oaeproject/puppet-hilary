class nginx (
    $internal_app_ips,
    $internal_etherpad_ips,
    $ux_root_dir      = '/opt/3akai-ux',
    $ux_admin_host    = 'admin.oae-performance.sakaiproject.org',
    $files_home       = '/opt/files',
    $ssl_path         = false,
    $cert_source      = 'puppet:///modules/localconfig/server.crt',
    $cert_key_source  = 'puppet:///modules/localconfig/server.key',
    $owner            = 'www',
    $group            = 'www',
    $nginx_dir        = '/opt/nginx',
    $installer_path   = '/tmp') {

  exec { 'installdir':
    command => "mkdir -p ${installer_path}",
    unless  => "test -d ${installer_path}",
  }

  file { 'nginx_script':
    path    => "${installer_path}/install.sh",
    ensure  => present,
    mode    => 0755,
    owner   => root,
    group   => root,
    content  => template('nginx/install.sh.erb'),
    require => Exec['installdir']
  }

  exec { 'nginx_install':
    cwd       => '/tmp',
    command   => "bash ${installer_path}/install.sh",
    logoutput => true,
    require   => File['nginx_script']
  }

  file { 'nginx_config':
    path    => "${nginx_dir}/conf/nginx.conf",
    ensure  => present,
    mode    => 0640,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx.conf.erb'),
    require => Exec['nginx_install']
  }

  # Init script
  file { '/etc/init.d/nginx':
    ensure  => present,
    mode    => 0744,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx-init-ubuntu.erb')
  }

  if ($ssl_path) {
    exec { 'mkdir_ssl_path':
      command => "mkdir -p ${ssl_path}",
      unless  => "test -d ${ssl_path}",
    }

    file { "${ssl_path}/server.crt":
      ensure  => present,
      mode    => 0400,
      owner   => $owner,
      group   => $group,
      source  => $cert_source,
      require => Exec['mkdir_ssl_path'],
      before  => Service['nginx'],
    }

    file { "${ssl_path}/server.key":
      ensure  => present,
      mode    => 0400,
      owner   => $owner,
      group   => $group,
      source  => $cert_key_source,
      require => Exec['mkdir_ssl_path'],
      before  => Service['nginx'],
    }
  }

  service { 'nginx':
    ensure  => running,
    require => [ File['/etc/init.d/nginx'], File['nginx_config'] ]
  }

}
