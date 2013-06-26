class oaeservice::munin::cassandra {

  # Munin needs to be installed before this class can be applied
  require '::oaeservice::munin::client'

  # Copy the plugins to the right place.
  file { '/etc/munin/plugins/cassandra_oae_users':
    ensure  => present,
    content => template('munin/plugins/cassandra/cassandra_oae_users'),
    mode    => 1777,
  }
}