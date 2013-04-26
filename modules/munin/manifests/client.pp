class munin::client {

  # Install the munin client package
  package { 'munin-node':
    ensure => installed,
  }

  # Configure it.
  file { '/etc/munin/munin-node.conf':
    ensure  => present,
    mode    => '0644',
    content => template('munin/munin-node.conf.erb'),
    require => Package['munin-node'],
  }

  # Start the service
  service { 'munin-node':
    ensure  => running,
    require => [ File['/etc/munin/munin-node.conf'] ],
  }

  # Use an exported file statement that gets collected on the client.
  @@file { "/etc/munin/munin-conf.d/$hostname":
     content  => template('munin/munin-client.conf.erb'),
     tag      => 'munin',
  }

}
