class cassandra (
    $owner              = 'cassandra',
    $group              = 'cassandra',
    $hosts              = [ '127.0.0.1' ],
    $listen_address     = 'null',
    $cluster_name       = 'Cassandra Cluster',
    $cassandra_home     = '/usr/share/cassandra',
    $cassandra_data_dir = '/data/cassandra',
    $initial_token      = '',
    $rsyslog_enabled    = false,
    $rsyslog_host       = '127.0.0.1',
    $dsc_version        = '2.0.9-1') {

  package { 'python-cql': ensure => installed }

  package { 'cassandra':
    ensure  => '2.0.9',
  }

  package { 'dsc20':
    ensure  => $dsc_version,
    alias   => 'dsc',
    require => [ Package['python-cql'], Package['cassandra'] ]
  }

  file { 'cassandra.yaml':
    path => '/etc/cassandra/cassandra.yaml',
    ensure => present,
    mode => 0640,
    owner => $owner,
    group => $group,
    content => template('cassandra/cassandra.yaml.erb'),
    require => Package['dsc'],
  }

  file { 'cassandra-env.sh':
    path => '/etc/cassandra/cassandra-env.sh',
    ensure => present,
    mode => 0755,
    owner => $owner,
    group => $group,
    content => template('cassandra/cassandra-env.sh.erb'),
    require => Package['dsc'],
  }

  file { 'log4j-server.properties':
    path    => '/etc/cassandra/log4j-server.properties',
    ensure  => present,
    mode    => 0755,
    owner   => $owner,
    group   => $group,
    content => template('cassandra/log4j-server.properties.erb'),
    require => Package['dsc'],
  }

  ## chown all the files in /etc/cassandra to the cassandra user.
  exec { "chown_cassandra":
    command => '/bin/chown -R cassandra:cassandra /etc/cassandra',
    require => File["cassandra.yaml", "cassandra-env.sh", "log4j-server.properties"],
  }

  ## Ensure the data directory exists
  exec { "mkdir_p_${cassandra_data_dir}":
    command => "/bin/mkdir -p ${cassandra_data_dir}/data ${cassandra_data_dir}/saved_caches"
  }

  exec { "chown_cassandra_data":
    command => "/bin/chown -R cassandra:cassandra ${cassandra_data_dir}",
    require => [ Exec["mkdir_p_${cassandra_data_dir}"], Package['dsc'] ],
  }

  # Start it.
  # Note that the default /etc/init.d/cassandra script has an invalid
  # status command. Puppet relies on a non-zero status code if cassandra
  # is stopped.
  service { 'cassandra':
    ensure     => 'running',
    require    => [Exec['chown_cassandra'], Exec['chown_cassandra_data']],
    enable     => 'true',
    hasstatus  => 'false',
  }

#  # Wait till we boot cassandra to boot the agent.
#  service { 'opscenter-agent':
#    ensure  => 'running',
#    require => Service['cassandra'],
#    enable  => 'true'
#  }

}
