class oaeservice::cassandra {

  $hosts = hiera('cassandra_hosts')
  $tokens = hiera('cassandra_tokens')
  $index = hiera('nodesuffix')

  class { '::cassandra':
    hosts               => $hosts,
    listen_address      => $hosts[$index],
    initial_token       => $tokens[$index],
    rsyslog_enabled     => hiera('rsyslog_enabled', false),
    rsyslog_host        => hiera('rsyslog_hosts'),
  }
}