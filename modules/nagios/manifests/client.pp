###################
## Nagios Client ##
###################

class nagios::client (
    $hostgroup   = 'misc'
  ){

  # Although it seems weird, nagios-nrpe-server is the daemon that needs to run on each host so the nagios monitor server can connect to it.
  $packages       = [ "nagios-plugins", "nagios-nrpe-server" ]
  $nrpe_cfg_path  = "/etc/nagios/nrpe.cfg"
  $nrpe_service   = "nagios-nrpe-server"
  $provider       = "apt"


  # Install the default set of nagios plugins and nrpe
  package { $packages:
    ensure   => present,
    provider => $provider,
  }

  # Configure nrpe
  file { $nrpe_cfg_path:
    ensure  =>  present,
    content =>  template("nagios/nrpe.cfg.erb"),
    require =>  Package[$packages],
    notify  =>  Service[$nrpe_service]
  }

  # The init script for nrpe, isn't too clever about where to store the pid
  # Make sure it can write to it.
  file { '/var/run/nagios/nrpe.pid':
    ensure  => present,
    owner   => 'nagios',
    group   => 'nagios',
    require =>  Package[$packages],
  }

  # Start the nrpe service
  service {$nrpe_service:
    ensure  => running,
    require => File['/var/run/nagios/nrpe.pid'],
  }

  #############################
  ## Nagios host information ##
  #############################

  @@nagios_host { $hostname:
    host_name   => $hostname,
    hostgroups  => $hostgroup,
    ensure      => present,
    alias       => $hostname,
    address     => $ipaddress_eth1,
    use         => "generic-host",
    target      => "/etc/nagios3/conf.d/puppet/hosts/$hostname.cfg",
  }

  @@nagios_hostextinfo { $hostname:
    ensure          => present,
    icon_image_alt  => $operatingsystem,
    icon_image      => "base/$operatingsystem.png",
    statusmap_image => "base/$operatingsystem.gd2",
    target          => "/etc/nagios3/conf.d/puppet/hostextinfo/$hostname.cfg",
  }


  ####################
  ## Default checks ##
  ####################
  
  file { '/usr/lib/nagios/plugins/check_security_updates':
    content => template('nagios/checks/check_security_updates'),
    mode    => 0755,
    owner   => 'nagios',
    group   => 'nagios',
    require => Package[$packages],
  }
  # The above command requires some sudo access
  file { '/etc/sudoers.d/nagios_security_check':
    ensure  => present,
    content => 'nagios localhost=/usr/bin/apt-get upgrade -qq -s -o Dir::Etc::SourceList==/tmp/security_list_only',
    mode    => 0440,
    owner   => root,
    group   => root,
  }

  @@nagios_service { "${hostname}_check_ping":
    use                 => "generic-service",
    service_description => "General::Ping",
    host_name           => "$hostname",
    check_command       => "check_ping!100.0,20%!500.0,60%",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-ping.cfg",
  }

  @@nagios_service { "${hostname}_check_ssh":
    use                 => "generic-service",
    service_description => "General::SSH",
    host_name           => "$hostname",
    check_command       => "check_ssh",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-ssh.cfg",
  }

  @@nagios_service { "${hostname}_check_load":
    use                 => "generic-service",
    service_description => "General::Load",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_load",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-load.cfg",
  }

  @@nagios_service { "${hostname}_check_users":
    use                 => "generic-service",
    service_description => "General::Users",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_users",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-users.cfg",
  }

  @@nagios_service { "${hostname}_check_security_updates":
    use                 => "generic-service",
    service_description => "General::Security updates",
    host_name           => "$hostname",
    check_command       => "check_nrpe_1arg!check_security_updates",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-security-update.cfg",
  }

  ##################
  ## Extra checks ##
  ##################

  # These are checks that should be present on some of the nodes.
  # Rather than sticking them in the oaeservice::nagios::xxx classes
  # and have some weird cross-dependency we let each host hold all the possible checks.
  # The oaeservice::nagios::xxx classes than add the correct 'service' to Nagios for a host.
  # These checks can then be added to nrpe and executed remotely.
  # The @@command resource should be specified in server.pp as these can only be defined ones.

  file { '/usr/lib/nagios/plugins/check_puppetmaster':
    content => template('nagios/checks/check_puppetmaster'),
    mode    => 0555,
    owner   => 'nagios',
    group   => 'nagios',
    require => Package[$packages],
  }

  file { '/usr/lib/nagios/plugins/check_free_memory':
    content => template('nagios/checks/check_free_memory'),
    mode    => 0555,
    owner   => 'nagios',
    group   => 'nagios',
    require => Package[$packages],
  }

  file { '/usr/lib/nagios/plugins/check_cassandra_query':
    content => template('nagios/checks/check_cassandra_query'),
    mode    => 0755,
    owner   => 'nagios',
    group   => 'nagios',
    require => Package[$packages],
  }

  # Create a check that pulls the JVM data from the REST Api
  file { '/usr/lib/nagios/plugins/check_elasticsearch_jvm':
    content => template('nagios/checks/check_elasticsearch_jvm'),
    mode    => 0555,
    owner   => 'nagios',
    group   => 'nagios',
    require => Package[$packages],
  }
}
