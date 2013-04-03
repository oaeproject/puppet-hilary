class nginx (
    $internal_app_ips,
    $internal_etherpad_ips,
    $ux_root_dir    = '/opt/3akai-ux',
    $ux_admin_host  = 'admin.oae-performance.sakaiproject.org',
    $files_home     = '/opt/files',
    $cert           = 'null',
    $cert_key       = 'null',
    $owner          = 'www',
    $group          = 'www',
    $nginx_dir      = '/opt/nginx',
    $installer_path = '/tmp') {

  case $operatingsystem {
    solaris, Solaris: {
      $nginx_ld_param = "--with-ld-opt='-L/opt/local/lib -Wl,-R/opt/local/lib'"
    }
    default: {
      $nginx_ld_param = ''
    }
  }

  exec { 'installdir':
    command => "mkdir -p ${installer_path}",
    unless  => "test -d ${installer_path}",
  }

  file { 'nginx_script':
    path    => "${installer_path}/install.sh",
    ensure  => present,
    mode    => 0700,
    owner   => root,
    group   => root,
    content  => template('nginx/install.sh.erb'),
    require => Exec['installdir']
  }

  exec { 'nginx_install':
    cwd       => '/tmp',
    command   => "${installer_path}/install.sh",
    require   => File['nginx_script']
  }

  file { 'nginx_config':
    path    => "<%= nginx_dir %>/conf/nginx.conf",
    ensure  => present,
    mode    => 0640,
    owner   => $owner,
    group   => $group,
    content => template('nginx/nginx.conf.erb'),
    require => Exec['nginx_install'],
  }

  case $operatingsystem {
    solaris, Solaris: {
      file { '/var/svc/manifest/nginx.xml':
        path    => '/var/svc/manifest/nginx.xml',
        ensure  => present,
        mode    => 0644,
        owner   => $owner,
        group   => $group,
        content => template('nginx/nginx.xml.erb')
      }

      exec { 'svccfg import /var/svc/manifest/nginx.xml':
        command => 'svccfg import /var/svc/manifest/nginx.xml',
        require => File['/var/svc/manifest/nginx.xml']
      }

      $nginx_require = Exec['svccfg import /var/svc/manifest/nginx.xml']
    }
    debian, ubuntu: {
      file { '/etc/init.d/nginx':
        ensure  => present,
        mode    => 0744,
        owner   => $owner,
        group   => $group,
        content => template('nginx/nginx-init-ubuntu.erb')
      }

      $nginx_require = File['/etc/init.d/nginx']
    }
    default: {
      exec { 'nginx_notsupported': command => fail("No support yet for ${::operatingsystem}") }
    }
  }

  service { 'nginx':
    ensure  => running,
    enable  => 'true',
    require => [ File['nginx_config'], $nginx_require ]
  }
}
