class oaeservice::nagios::postfix {

    # Make sure that the nagios service gets applied first.
    Class['::nagios::client'] -> Class['::oaeservice::nagios::mailq']

    # Add a check that will monitor the amount of pending emails
    @@nagios_service { "${hostname}_check_postfix_mailq":
        use                 => "generic-service",
        service_description => "Postfix::Mailqueue",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_postfix_mailq",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-postfix-mailq.cfg",
    }
}
