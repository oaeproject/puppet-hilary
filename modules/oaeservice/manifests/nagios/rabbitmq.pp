class oaeservice::nagios::rabbitmq  {


  @@nagios_service { "${hostname}_check_rabbitmq_aliveness":
    use                 => "generic-service",
    service_description => "RabbitMQ::Alive",
    host_name           => "$hostname",
    check_command       => "check_rabbitmq_aliveness",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-rabbitmq-aliveness.cfg",
  }

  # The first argument is the warning level, the second the critical
  # levels for each count of messages, messages_ready and messages_unacknowledged.  A field consists of three comma-separated integers.
  @@nagios_service { "${hostname}_check_rabbitmq_search_reindex":
    use                 => "generic-service",
    service_description => "RabbitMQ::Queue::Search::Reindex",
    host_name           => "$hostname",
    check_command       => "check_rabbitmq_queue!oae-search%2Freindex!10,10,10!20,20,20",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-rabbitmq-queue-search-reindex.cfg",
  }

  @@nagios_service { "${hostname}_check_rabbitmq_queue_search_index":
    use                 => "generic-service",
    service_description => "RabbitMQ::Queue::Search::Index",
    host_name           => "$hostname",
    check_command       => "check_rabbitmq_queue!oae-search%2Findex!200,200,10!300,300,20",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-rabbitmq-queue-search-index.cfg",
  }

  @@nagios_service { "${hostname}_check_rabbitmq_queue_search_delete":
    use                 => "generic-service",
    service_description => "RabbitMQ::Queue::Search::Delete",
    host_name           => "$hostname",
    check_command       => "check_rabbitmq_queue!oae-search%2Fdelete!200,200,10!300,300,20",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-rabbitmq-queue-search-delete.cfg",
  }

  @@nagios_service { "${hostname}_check_rabbitmq_queue_pp_generate":
    use                 => "generic-service",
    service_description => "RabbitMQ::Queue::Previews::Generate",
    host_name           => "$hostname",
    check_command       => "check_rabbitmq_queue!oae-preview-processor%2FgeneratePreviews!300,300,10!400,400,20",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-rabbitmq-queue-pp-generate.cfg",
  }

  @@nagios_service { "${hostname}_check_rabbitmq_queue_pp_regenerate":
    use                 => "generic-service",
    service_description => "RabbitMQ::Queue::Previews::Regenerate",
    host_name           => "$hostname",
    check_command       => "check_rabbitmq_queue!oae-preview-processor%2FregeneratePreviews!200,200,10!300,300,10",
    target              => "/etc/nagios3/conf.d/puppet/services/$hostname-check-rabbitmq-queue-pp-regenerate.cfg",
  }

}