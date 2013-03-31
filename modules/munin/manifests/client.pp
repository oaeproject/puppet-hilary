class munin::client ($hostname) {

  case $operatingsystem {
    solaris, Solaris: {
      $provider = 'pkgin'
      $etc_dir = '/opt/local/etc'
    }
    default: {
      $provider = undef
      $etc_dir = '/etc'
    }
  }

  package { 'munin-node': ensure => installed, provider => $provider }

  file { "$etc_dir/munin/munin-node.conf":
    ensure  => present,
    mode    => '0644',
    content => template('munin/munin-node.conf.erb'),
    require => Package['munin-node'],
  }

  service { 'munin-node':
    ensure  => running,
    require => [ File["$etc_dir/munin/munin-node.conf"] ]
  }

}
