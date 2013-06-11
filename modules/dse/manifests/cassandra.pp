class dse::cassandra (
    $dse_username,
    $dse_password,
    $dse_package        = 'dse-full',
    $dse_version        = '3.0.2-1',
    $owner              = 'cassandra',
    $group              = 'cassandra',
    $cluster_name       = 'Apereo OAE Cluster',
    $num_tokens         = 256,
    $hosts              = [ '127.0.0.1' ],
    $listen_address     = '',
    $cassandra_home_dir = '/var/lib/cassandra',
    $cassandra_data_dir = '/data/cassandra',
    $rsyslog_enabled    = false,
    $rsyslog_host       = '127.0.0.1') {

  include apt
  apt::source { 'dse':
    location    => "http://$dse_username:$dse_password@debian.datastax.com/enterprise",
    repos       => 'stable main',
    release     => '',
    key_source  => 'http://debian.datastax.com/debian/repo_key',
    key         => 'B4FE9662',
  }

  package { $dse_package: ensure => $dse_version }

  #file { 'cassandra.yaml':
  #  path => '/etc/dse/cassandra/cassandra.yaml',
  #  ensure => present,
  #  mode => 0640,
  #  owner => $owner,
  #  group => $group,
  #  content => template('dse/cassandra.yaml.erb'),
  #  require => Package[$dse_package],
  #}

  #file { 'cassandra-env.sh':
  #  path => '/etc/dse/cassandra/cassandra-env.sh',
  #  ensure => present,
  #  mode => 0755,
  #  owner => $owner,
  #  group => $group,
  #  content => template('dse/cassandra-env.sh.erb'),
  #  require => Package[$dse_package],
  #}

  #file { 'log4j-server.properties':
  #  path    => '/etc/dse/cassandra/log4j-server.properties',
  #  ensure  => present,
  # mode    => 0755,
  # owner   => $owner,
  # group   => $group,
  # content => template('dse/log4j-server.properties.erb'),
  # require => Package[$dse_package],
  #}

  file { '/etc/security/limits.conf':
    ensure  =>  present,
    content =>  template('dse/limits.conf.erb'),
  }

  ## Further set system limits:
  exec { 'sysctl-max-map-count':
    command   =>  'sysctl -w vm.max_map_count=131072',
    subscribe =>  File['/etc/security/limits.conf'],
  }

  ## chown all the files in /etc/dse/cassandra to the cassandra user.
  #exec { "chown_cassandra":
  #  command => '/bin/chown -R cassandra:cassandra /etc/dse/cassandra',
  #  require => File["cassandra.yaml"] #, "cassandra-env.sh", "log4j-server.properties"],
  #}

  ## Ensure the data directory exists
  #exec { "mkdir_p_${cassandra_data_dir}":
  #  command => "mkdir -p ${cassandra_data_dir}/data ${cassandra_data_dir}/saved_caches",
  #  creates => "${cassandra_data_dir}/saved_caches",
  #}

  #exec { "chown_cassandra_data":
  #  command => "/bin/chown -R cassandra:cassandra ${cassandra_data_dir}",
  #  require => [ Exec["mkdir_p_${cassandra_data_dir}"], Package[$dse_package] ],
  #}

  # Start it.
  # Note that the default /etc/init.d/cassandra script has an invalid
  # status command. Puppet relies on a non-zero status code if cassandra
  # is stopped.
  service { 'dse':
    ensure     => 'running',
    # require    => [Exec['chown_cassandra'], Exec['chown_cassandra_data']],
  }

#  # Wait till we boot cassandra to boot the agent.
#  service { 'opscenter-agent':
#    ensure  => 'running',
#    require => Service['cassandra'],
#    enable  => 'true'
#  }

}
