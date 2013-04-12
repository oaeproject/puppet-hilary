class oaeservice::firewall::web {
  # Accept SSH traffic on the public interface
  iptables { '001 allow public web traffic':
    chain   => 'INPUT',
    iniface => 'eth0',
    proto   => 'tcp',
    dport   => [80, 443],
    jump    => 'ACCEPT',
  }
}