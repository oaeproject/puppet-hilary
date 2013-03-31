class munin::client ($hostname) {

  case $operatingsystem {
    solaris, Solaris: {
      $provider = 'pkgin'
    }
    default: {
      $provider = undef
    }
  }

  package { 'munin-node': ensure => installed, provider => $provider }

  file { '/etc/munin/munin-node.conf':
    ensure  => file,
    mode    => '0644',
    content => template('munin/munin-node.conf.erb'),
    require => Package['munin-node'],
  }

  service { 'munin-node':
    ensure  => running,
    require => [ File['/etc/munin/munin-node.conf'] ]
  }

}
