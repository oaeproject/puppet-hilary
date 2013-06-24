class nginx (
    $internal_app_ips,
    $internal_etherpad_ips,
    $web_domain,
    $etherpad_external_domain_label   = 'etherpad',
    $app_admin_tenant                 = 'admin',
    $ux_root_dir                      = '/opt/3akai-ux',
    $files_home                       = '/opt/files',
    $ssl_path                         = false,
    $cert_source                      = 'puppet:///modules/localconfig/server.crt',
    $cert_key_source                  = 'puppet:///modules/localconfig/server.key',
    $owner                            = 'root',
    $group                            = 'root',
    $nginx_dir                        = '/etc/nginx') {

  include apt
  apt::source { 'nginx':
    location    => 'http://nginx.org/packages/ubuntu/',
    repos       => 'nginx',
    key         => 'ABF5BD827BD9BF62',
  }

  package { 'nginx=1.4.1-1~precise':
    ensure  => installed,
    alias   => 'nginx',
    require => Class['apt'],
  }

  file { 'nginx_config':
    path    => "${nginx_dir}/nginx.conf",
    ensure  => present,
    mode    => 0640,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx.conf.erb'),
    require => Package['nginx'],
  }

  file { 'nginx_mime_types':
    path    => "${nginx_dir}/nginx.mime.types",
    ensure  => present,
    mode    => 0640,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx.mime.types'),
    require => Package['nginx'],
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

  # Init script for ubuntu
  file { '/etc/init.d/nginx':
    ensure  => present,
    mode    => 0744,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx-init-ubuntu.erb')
  }

  service { 'nginx':
    ensure  => running,
    require => [ Package['nginx'], File['nginx_config'], File['nginx_mime_types'], File['/etc/init.d/nginx'] ]
  }

}
