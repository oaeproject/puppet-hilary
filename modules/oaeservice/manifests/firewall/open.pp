class oaeservice::firewall::open {
  include oaeservice::firewall
  iptables { '001 allow all input':   chain => 'INPUT',   iniface => 'eth0', jump => 'ACCEPT' }
  iptables { '001 allow all forward': chain => 'FORWARD', iniface => 'eth0', jump => 'ACCEPT' }
}