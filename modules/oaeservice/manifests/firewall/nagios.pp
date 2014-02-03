class oaeservice::firewall::nagios {
  # Accept WEB traffic on the public interface to nagios (8090)
  iptables { '003 allow nagios traffic':
    chain   => 'INPUT',
    iniface => 'eth0',
    proto   => 'tcp',
    dport   => [8090],
    jump    => 'ACCEPT',
  }
}