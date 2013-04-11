class munin::client ($hostname) {

  package { 'munin-node': ensure => installed }

  file { '/etc/munin/munin-node.conf':
    ensure  => present,
    mode    => '0644',
    content => template('munin/munin-node.conf.erb'),
    require => Package['munin-node'],
  }

  service { 'munin-node':
    ensure  => running,
    require => [ File['/etc/munin/munin-node.conf'] ]
  }

}
