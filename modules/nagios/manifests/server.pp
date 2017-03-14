
###################
## Nagios Server ##
###################

#
# Parameters:
#    http_username        - The username to log onto the nagios web console
#    http_password        - The (encrypted) password to log onto the nagios web console. This can be generated with `htpasswd`
#    enable_notifications - Whether or not to enable notifications.
#
class nagios::server (
    $http_username = 'nagiosadmin',
    $http_password = '$apr1$jdYkGn4R$C/zBGqUA1.Zkra8U4vmNH1',
    $enable_notifications = false
  ){

  ###################
  ## Nagios Server ##
  ###################

  # Install the nagios packages.
  $packages = ['nagios3', 'nagios-nrpe-plugin', ]
  package { $packages:
    ensure      => installed,
  }

  $nagios_directories = [ '/etc/nagios3/conf.d',
                          '/etc/nagios3/conf.d/puppet',
                          '/etc/nagios3/conf.d/puppet/hosts',
                          '/etc/nagios3/conf.d/puppet/hostextinfo',
                          '/etc/nagios3/conf.d/puppet/services',
                          '/etc/nagios3/conf.d/puppet/hostgroups',
                          '/etc/nagios3/conf.d/puppet/commands',
                          '/etc/nagios3/conf.d/puppet/contacts'
                        ]
  $nagios_default_files = [ '/etc/nagios3/conf.d/hostgroups_nagios2.cfg',
                            '/etc/nagios3/conf.d/localhost_nagios2.cfg',
                            '/etc/nagios3/conf.d/services_nagios2.cfg',
                            '/etc/nagios3/conf.d/extinfo_nagios2.cfg',
                            '/etc/nagios3/conf.d/generic-service_nagios2.cfg',
                            '/etc/nagios3/conf.d/generic-host_nagios2.cfg',
                            '/etc/nagios3/commands.cfg',
                          ]

  # Create all the directories where we'll be placing files.
  file { $nagios_directories:
    ensure      => 'directory',
    require     => Package[$packages],
    owner       => 'nagios',
    group       => 'nagios',
    recurse     => 'true',
  }

  # Remove the default nagios files.
  file { $nagios_default_files:
    ensure  => absent,
    require => Package[$packages],
  }

  # The main nagios config.
  file { '/etc/nagios3/nagios.cfg':
    ensure  => present,
    content => template('nagios/nagios.cfg.erb'),
    require => Package[$packages],
  }

  file { '/usr/share/nagios3/htdocs/images/logos/base/Ubuntu.png':
    ensure  => present,
    content => template('nagios/Ubuntu.png'),
    require => Package[$packages],
  }

  # Start the service.
  service { 'nagios3':
    ensure      => running,
    hasstatus   => true,
    hasrestart  => true,
    require     => [ Package[$packages], File[$nagios_directories], File[$nagios_default_files], File['/etc/nagios3/nagios.cfg'] ]
  }

  # The nagios service will wreck the nagios.cmd file. If we chown and chmod that stupid thing, we can reschedule checks
  # from the web console.
  exec { 'chown_cmd_file':
    command => 'chown -R nagios:www-data /var/lib/nagios3',
    require => Service['nagios3'],
  }

  exec { 'chmod_cmd_file':
    command     => 'chmod -R g+x /var/lib/nagios3/rw',
    require => Service['nagios3'],
  }

  # Create all nagios configs before restarting nagios
  File[$nagios_directories] -> Nagios_host <| |> -> Service['nagios3']
  File[$nagios_directories] -> Nagios_hostextinfo <| |> -> Service['nagios3']
  File[$nagios_directories] -> Nagios_hostgroup <| |> -> Service['nagios3']
  File[$nagios_directories] -> Nagios_service <| |> -> Service['nagios3']
  File[$nagios_directories] -> Nagios_command <| |> -> Service['nagios3']
  File[$nagios_directories] -> Nagios_contact <| |> -> Service['nagios3']
  File[$nagios_directories] -> Nagios_contactgroup <| |> -> Service['nagios3']

  # Configure Apache2 to host nagios.
  # This assumes Apache2 is present.
  file { '/etc/apache2/sites-enabled/000-nagios':
    ensure  => present,
    content => template('nagios/000-nagios'),
    notify  => Service['apache2'],
    require => Package[$packages],
  }

  file { '/etc/nagios3/htpasswd.users':
    ensure  => present,
    content => "$http_username:$http_password",
    require => Package[$packages],
  }

  service { 'apache2':
    ensure  => 'running',
    require => File['/etc/apache2/sites-enabled/000-nagios'],
  }

  # Workaround for http://projects.puppetlabs.com/issues/3299
  exec { 'chown_nagios_configs':
    path        => ['/usr/bin', '/usr/sbin'],
    command     => '/bin/chown -R nagios:nagios /etc/nagios3/conf.d/puppet',
    refreshonly => true,
    notify      => Service['nagios3'],
  }

  #####################
  ## Nagios metadata ##
  #####################

  # Collect resources and populate them in the /etc/nagios folder
  Nagios_host <<||>> {
    notify      => Exec['chown_nagios_configs'],
  }
  Nagios_service <<||>> {
    notify      => Exec['chown_nagios_configs'],
  }
  Nagios_hostextinfo <<||>> {
    notify      => Exec['chown_nagios_configs'],
  }
  Nagios_command <<||>> {
    notify      => Exec['chown_nagios_configs'],
  }
  Nagios_contact <<||>> {
    notify      => Exec['chown_nagios_configs'],
  }
  Nagios_contactgroup <<||>> {
    notify      => Exec['chown_nagios_configs'],
  }

  # Overwrite the generic service
  nagios_service { 'generic-service':
    target                        =>   '/etc/nagios3/conf.d/puppet/generic-command.cfg',
    require                       =>   File[$nagios_directories],
    name                          =>   'generic-service',
    active_checks_enabled         =>   1,       # Active service checks are enabled
    passive_checks_enabled        =>   1,       # Passive service checks are enabled/accepted
    parallelize_check             =>   1,       # Active service checks should be parallelized (disabling this can lead to major performance problems)
    obsess_over_service           =>   1,       # We should obsess over this service (if necessary)
    check_freshness               =>   0,       # Default is to NOT check service 'freshness'
    notifications_enabled         =>   1,       # Service notifications are enabled
    event_handler_enabled         =>   1,       # Service event handler is enabled
    flap_detection_enabled        =>   1,       # Flap detection is enabled
    failure_prediction_enabled    =>   1,       # Failure prediction is enabled
    process_perf_data             =>   1,       # Process performance data
    retain_status_information     =>   1,       # Retain status information across program restarts
    retain_nonstatus_information  =>   1,       # Retain non-status information across program restarts
    notification_interval         =>   60,      # This directive is used to define the number of "time units" to wait before re-notifying a contact that this service is still in a non-OK state. Unless you've changed the interval_length directive from the default value of 60, this number will mean minutes. If you set this value to 0, Nagios will not re-notify contacts about problems for this service - only one problem notification will be sent out.
    first_notification_delay      =>   0,       # This directive is used to define the number of "time units" to wait before sending out the first problem notification when this host enters a non-UP state. Unless you've changed the interval_length directive from the default value of 60, this number will mean minutes. If you set this value to 0, Nagios will start sending out notifications immediately.
    is_volatile                   =>   0,
    check_period                  =>   '24x7',
    normal_check_interval         =>   5,
    retry_check_interval          =>   1,
    max_check_attempts            =>   4,
    notification_period           =>   '24x7',
    notification_options          =>   'w,u,c,r,f,s',
    contact_groups                =>   'oae-admins',
    register                      =>   '0',     # Active service checks are enabled
  }

  # Overwrite the generic host
  nagios_host { 'generic-host':
    target                        =>  '/etc/nagios3/conf.d/puppet/generic-host.cfg',
    require                       =>  File[$nagios_directories],
    name                          =>  'generic-host',
    active_checks_enabled         =>   1,       # Active host checks are enabled
    passive_checks_enabled        =>   1,       # Passive host checks are enabled/accepted
    notifications_enabled         =>   1,       # Host notifications are enabled
    event_handler_enabled         =>   1,       # Host event handler is enabled
    flap_detection_enabled        =>   1,       # Flap detection is enabled
    failure_prediction_enabled    =>   1,       # Failure prediction is enabled
    process_perf_data             =>   1,       # Process performance data
    retain_status_information     =>   1,       # Retain status information across program restarts
    retain_nonstatus_information  =>   1,       # Retain non-status information across program restarts
    notification_interval         =>   60,      # This directive is used to define the number of "time units" to wait before re-notifying a contact that this service is still in a non-OK state. Unless you've changed the interval_length directive from the default value of 60, this number will mean minutes. If you set this value to 0, Nagios will not re-notify contacts about problems for this service - only one problem notification will be sent out.
    first_notification_delay      =>   0,       # This directive is used to define the number of "time units" to wait before sending out the first problem notification when this host enters a non-UP state. Unless you've changed the interval_length directive from the default value of 60, this number will mean minutes. If you set this value to 0, Nagios will start sending out notifications immediately.
    max_check_attempts            =>   3,       #    This directive is used to define the number of times that Nagios will retry the host check command if it returns any state other than an OK state. Setting this value to 1 will cause Nagios to generate an alert without retrying the host check. Note: If you do not want to check the status of the host, you must still set this to a minimum value of 1. To bypass the host check, just leave the check_command option blank.
    check_command                 =>   'check-host-alive',
    contact_groups                =>   'oae-admins',
    notification_period           =>   '24x7',
    notification_options          =>   'd,u,r,f,s',
    register                      =>   '0',     # Active service checks are enabled
  }

  nagios_contactgroup { 'oae-admins':
    target        => '/etc/nagios3/conf.d/puppet/contacts/oae-admins.cfg',
    alias         => 'Administrators',
    require       =>  File[$nagios_directories],
  }

  # Create all the possible hostgroups.
  nagios_hostgroup {'nagios_hostgroup_webservers':
    alias           =>  'Web Servers',
    hostgroup_name  =>  'webservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/webservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_appservers':
    alias           =>  'Application Servers',
    hostgroup_name  =>  'appservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/appservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_dbservers':
    alias           =>  'DB Servers',
    hostgroup_name  =>  'dbservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/dbservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_searchservers':
    alias           =>  'Search Servers',
    hostgroup_name  =>  'searchservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/searchservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_ppservers':
    alias           =>  'Preview Processors',
    hostgroup_name  =>  'ppservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/ppservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_cachingservers':
    alias           =>  'Caching Servers',
    hostgroup_name  =>  'cacheservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/cacheservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_activityservers':
    alias           =>  'Activity Servers',
    hostgroup_name  =>  'activityservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/activityservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_etherpadservers':
    alias           =>  'Etherpad Servers',
    hostgroup_name  =>  'etherpadservers',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/etherpadservers.cfg',
    require         =>  File[$nagios_directories],
  }
  nagios_hostgroup {'nagios_hostgroup_miscservers':
    alias           =>  'Miscellaneous',
    hostgroup_name  =>  'misc',
    target          =>  '/etc/nagios3/conf.d/puppet/hostgroups/misc.cfg',
    require         =>  File[$nagios_directories],
  }

  # Create the notification commands.
  nagios_command { 'notify-host-by-email':
    target          => '/etc/nagios3/conf.d/puppet/commands/notify-host-by-email.cfg',
    command_line    => "/usr/bin/printf \"%b\" \"***** OAE Monitoring Alert *****\\n\\nNotification Type: \$NOTIFICATIONTYPE\$\\nHost: \$HOSTNAME\$\\nState: \$HOSTSTATE\$\\nAddress: \$HOSTADDRESS\$\\nInfo: \$HOSTOUTPUT\$\\n\\nDate/Time: \$LONGDATETIME\$\\n\" | /usr/bin/mail -a \"From: Nagios_Alerting\" -s \"[Nagios]  \$NOTIFICATIONTYPE\$ Host Alert: \$HOSTNAME\$ is \$HOSTSTATE\$\" \$CONTACTEMAIL\$",
    ensure          => 'present',
    require         =>  File[$nagios_directories],
  }

  nagios_command { 'notify-service-by-email':
    target          => '/etc/nagios3/conf.d/puppet/commands/notify-service-by-email.cfg',
    command_line    => "/usr/bin/printf \"%b\" \"***** OAE Monitoring Alert *****\\n\\nNotification Type: \$NOTIFICATIONTYPE\$\\nHost: \$HOSTNAME\$\\nState: \$HOSTSTATE\$\\nService output: \$SERVICEOUTPUT\$ \$LONGSERVICEOUTPUT\$\\nAddress: \$HOSTADDRESS\$\\nInfo: \$HOSTOUTPUT\$\\n\\nDate/Time: \$LONGDATETIME\$\\n\" | /usr/bin/mail -a \"From: Nagios_Alerting\" -s \"[Nagios] \$NOTIFICATIONTYPE\$ Service Alert on \$HOSTNAME\$: \$SERVICEDESC\$ - \$SERVICESTATE\$\" \$CONTACTEMAIL\$",
    ensure          => 'present',
    require         =>  File[$nagios_directories],
  }



  #####################################
  ## Dependencies for nagios checks. ##
  #####################################

  # We need some perl voodoo so we can install the Nagios::Plugin
  class { 'cpanm::install':
    libraries => [ 'URI', 'JSON', 'LWP::UserAgent', 'http://search.cpan.org/CPAN/authors/id/T/TO/TONVOON/Nagios-Plugin-0.36.tar.gz' ]
  }


  vcsrepo { '/tmp/nagios-plugins-rabbitmq':
    ensure    => latest,
    provider  => git,
    source    => 'https://github.com/jamesc/nagios-plugins-rabbitmq.git',
    revision  => 'master',
    notify    => Exec['copy-nagios-rabbitmq-scripts'],
  }

  exec { 'copy-nagios-rabbitmq-scripts':
    require   => [ Class['nagios::client'], Vcsrepo['/tmp/nagios-plugins-rabbitmq'] ],
    command   => '/bin/cp /tmp/nagios-plugins-rabbitmq/scripts/* /usr/lib/nagios/plugins/',
  }

  nagios_command { 'check_rabbitmq_aliveness':
    target              => '/etc/nagios3/conf.d/puppet/commands/check_rabbitmq_aliveness.cfg',
    command_line        => '/usr/lib/nagios/plugins/check_rabbitmq_aliveness -H $HOSTADDRESS$ --port 15672',
    ensure              => 'present',
    require             =>  File[$nagios_directories],
  }

  nagios_command { 'check_rabbitmq_queue':
    target              => '/etc/nagios3/conf.d/puppet/commands/check_rabbitmq_queue.cfg',
    command_line        => '/usr/lib/nagios/plugins/check_rabbitmq_queue -H $HOSTADDRESS$ --queue $ARG1$ -w $ARG2$ -c $ARG3$ --port 15672',
    ensure              => 'present',
    require             =>  File[$nagios_directories],
  }

  # ARG1 and ARG2 need to be 4 commaseparated integers.
  # ex: 80,80,80,80 and 90,90,90,90
  nagios_command { 'check_rabbitmq_server':
    target              => '/etc/nagios3/conf.d/puppet/commands/check_rabbitmq_server.cfg',
    command_line        => '/usr/lib/nagios/plugins/check_rabbitmq_aliveness -H $HOSTADDRESS$ -w $ARG1$ -c $ARG2$ --port 15672',
    ensure              => 'present',
    require             =>  File[$nagios_directories],
  }

  # Checks the free amount of memory
  nagios_command { 'check_free_memory':
    command_name        => 'check_free_memory',
    target              => '/etc/nagios3/conf.d/puppet/commands/check_free_memory.cfg',
    command_line        => '/usr/lib/nagios/plugins/check_free_memory',
    ensure              => 'present',
    require             =>  File[$nagios_directories],
  }

  # Create a command that runs a query against cassandra
  nagios_command { 'check_cassandra_query':
    target              => '/etc/nagios3/conf.d/puppet/commands/check_cassandra_query.cfg',
    command_line        => '/usr/lib/nagios/plugins/check_cassandra_query',
    ensure              => 'present',
    require             =>  File[$nagios_directories],
  }

  # Create a command to check if puppet ran on all nodes.
  nagios_command { 'check_puppetmaster':
    target              => '/etc/nagios3/conf.d/puppet/commands/check_puppetmaster.cfg',
    command_line        => '/usr/bin/sudo /usr/lib/nagios/plugins/check_puppetmaster',
    ensure              => 'present',
    require             =>  File[$nagios_directories],
  }

  # The above command requires some sudo access
  file { '/etc/sudoers.d/nagios_puppetmaster_check':
    ensure  => present,
    content => "Defaults env_reset\n\nnagios ALL=(ALL) NOPASSWD: /usr/lib/nagios/plugins/check_puppetmaster\n",
    mode    => 0440,
    owner   => root,
    group   => root,
  }

  # for the nagios server to monitor it's own mailq with sms alerts
  $monitoring_mailq_maxalerts = hiera('monitoring_mailq_maxalerts')
  $monitoring_mailq_maxsize = hiera('monitoring_mailq_maxsize')
  $adminphones = hiera('adminphones')
  $smsbroadcast_user = hiera('smsbroadcast_user')
  $smsbroadcast_pass = hiera('smsbroadcast_pass')

  file { 'monitormailq.sh':
    path    => "/usr/local/bin/monitormailq.sh",
    mode    => 0755,
    content => template('nagios/monitormailq.sh.erb'),
    ensure  => present,
  }

  cron { 'monitoring-mailq':
    ensure  => present,
    command => '/usr/local/bin/monitormailq.sh',
    user    => 'root',
    target  => 'root',
    minute  => '*/5',
    require => File['monitormailq.sh'],
  }

  # used for detecting lock files
  nagios_command { 'check_file_notexist':
    target              => '/etc/nagios3/conf.d/puppet/commands/check_file_notexist.cfg',
    command_line        => '/usr/lib/nagios/plugins/check_file_notexist $ARG1$',
    ensure              => 'present',
    require             => File[$nagios_directories],
  }

}

