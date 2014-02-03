class oaeservice::nagios::mail {

    # Make sure that the nagios service gets applied first.
    Class['::nagios::client'] -> Class['::oaeservice::nagios::mail']

    # Add a check that will monitor the amount of pending emails
    @@nagios_service { "${hostname}_check_postfix_mailq":
        use                 => "generic-service",
        service_description => "Mail::queued",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_postfix_mailq",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-postfix-mailq.cfg",
    }

    # Add a check that will monitor the total amount of emails being sent in a day
    @@nagios_service { "${hostname}_check_mails_sent":
        use                 => "generic-service",
        service_description => "Mail::sent",
        host_name           => "$hostname",
        check_command       => "check_nrpe_1arg!check_mails_sent",
        target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-mails-sent.cfg",
    }
}
