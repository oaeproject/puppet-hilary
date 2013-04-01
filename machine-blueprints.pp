
########################
########################
## MACHINE BLUEPRINTS ##
########################
########################

##
# "Machine Blueprints" are high-level class definitions that represent pre-canned services that are common
# to each type of machine. These blueprints should be portable (either as-is or by parameter configuration)
# across all environments (e.g., performance, production, staging, ...).
#
# Therefore, only add resources within these classes that will be added to this type of machine for all
# environments.
##



##################
## BASE MACHINE ##
##################

class machine::base {
  service::rsyslog::client { 'service-rsyslog-client': }
}

class machine ($type_code, $suffix) inherits machine::base {
  service-munin-client { 'service-munin-client': type_code => $type_code, suffix => $suffix }
}



#################
## APP MACHINE ##
#################

class machine::app::base inherits machine::base {
  Service-munun-client['service-munin-client'] { type_code => 'app' }
  class { 'service::hilary::app': }
}

class machine::app ($index) inherits machine::app::base {
  Service-munun-client['service-munin-client'] { suffix => $index }
}



###############################
## PREVIEW PROCESSOR MACHINE ##
###############################

class machine::pp::base inherits machine::base {
  Service-munun-client['service-munin-client'] { type_code => 'pp' }
  class { 'service::hilary::pp': }
}

class machine::pp ($index) inherits machine::pp::base {
  Service-munun-client['service-munin-client'] { suffix => $index }
}


################
## DB MACHINE ##
################

class machine::db::base inherits machine::base {
  include service::firewall
  Service-munun-client['service-munin-client'] { type_code => 'db' }
  service::cassandra { 'service-cassandra': }
}

class machine::db ($index) inherits machine::db::base {
  Service-munun-client['service-munin-client'] { suffix => $index }
  Service::Cassandra['service-cassandra'] { index => $index }
}



####################
## SEARCH MACHINE ##
####################

class machine::search::base inherits machine::base {
  include service::firewall

  Service-munun-client['service-munin-client'] { type_code => 'search' }
  service::elasticsearch { 'service-elasticsearch': }
}

class machine::search ($index) inherits machine::search::base {
    Service-munun-client['service-munin-client'] { suffix => $index }
    Service::Elasticsearch['service-elasticsearch'] { index => $index }
}



######################
## ETHERPAD MACHINE ##
######################

class machine::ep::base inherits machine::base {
  Service-munun-client['service-munin-client'] { type_code => 'ep' }
  service::etherpad { 'service-etherpad': }
}

class machine::ep ($index) inherits machine::ep::base {
  Service-munun-client['service-munin-client'] { suffix => $index }
  Service::Etherpad['service-etherpad'] { index => $index }
}



####################
## DRIVER MACHINE ##
####################

class machine::driver {
  class { 'tsung': }

  package { 'nginx':
    ensure    => present,
    provider  => pkgin,
  }

  service { 'nginx':
    ensure  => running,
    enable  => true,
    require => Package['nginx'],
  }
}



#################
## WEB MACHINE ##
#################

class machine::web::base inherits machine::base {
  Service-munun-client['service-munin-client'] { type_code => 'web' }
  Service::Rsyslog::Client['service-rsyslog-client'] {
    imfiles => [
      # Access log
      {
        path                  => '/var/log/nginx/access.log',
        tag                   => 'access',
        state_file_name       => 'nginx_access',
        severity              => 'info',
        facility              => 'local0',
        poll_interval_seconds => 10,
      },
      # Error log
      {
        path                  => '/var/log/nginx/error.log',
        tag                   => 'error',
        state_file_name       => 'nginx_error',
        severity              => 'error',
        facility              => 'local1',
        poll_interval_seconds => 10,
      },
    ]
  }

  service::nginx { 'service-nginx': }
}

class machine::web ($index) inherits machine::web::base {
  Service-munun-client['service-munin-client'] { suffix => $index }
}



####################
## SYSLOG MACHINE ##
####################

class machine::syslog {
  service::munin::client { 'service-munin-client': type_code => 'syslog' }
  service::rsyslog::server { 'service-rsyslog-server': }
}



#####################
## BASTION MACHINE ##
#####################

## TODO: Install VPN n' stuff
class machine::bastion inherits machine::base {

  ## Allow forwarding with sysctl
  sysctl::value {
    'net.ipv4.ip_forward': value => '1',
    notify => Exec['load-sysctl'],
  }

  exec { 'load-sysctl':
    command => 'sysctl -p /etc/sysctl.conf',
    refreshonly => true,
  }

  # Accept SSH traffic on the public interface
  iptables { '001 allow public ssh traffic':
    chain   => 'INPUT',
    iniface => 'eth0',
    proto   => 'tcp',
    dport   => 22,
    jump    => 'ACCEPT',
  }
}



####################
## ATREYU MACHINE ##
####################

## a.k.a., a machine to hold many "other" components like nagios, munin server, opscenter
