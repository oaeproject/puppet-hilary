class oaeservice::firewall {
  
  case $operatingsystem {
    solaris, Solaris: {
      class { 'ipfilter': }
    }
    default: {

      ####################
      ## FIREWALL SETUP ##
      ####################
      #
      # By default, allow:
      #
      #   1.  Drop invalid packets
      #   2.  everything on private and loopback interfaces, and established input traffic
      #   3.  all outgoing traffic, including public interfaces
      #
      # By default, deny:
      #
      #   4. all incoming and forward traffic not white-listed above
      #
      # It is expected that any node that needs additional firewall rules opened will specify a rule with a
      # "jump => 'ACCEPT'", with a resource name that is greater than 000 and less than 900. E.g.: to open
      # https traffic on the elasticsearch public interface (for some reason), in your class manifest, include:
      #
      # iptables { '001 elasticsearch http':
      #   chain => 'INPUT',
      #   dport => 'https',
      #   jump  => 'ACCEPT',
      # }
      #

      # 1.
      iptables { '000 kill invalid input on public':
        chain     => 'INPUT',
        iniface   => 'eth0',
        state     => 'INVALID',
        jump      => 'DROP',
      }

      iptables { '000 kill invalid forward on public':
        chain     => 'FORWARD',
        iniface   => 'eth0',
        state     => 'INVALID',
        jump      => 'DROP',
      }

      iptables { '000 kill invalid output on public':
        chain     => 'OUTPUT',
        outiface  => 'eth0',
        state     => 'INVALID',
        jump      => 'DROP',
      }

      # 2.
      iptables { '998 allow private input': chain => 'INPUT', iniface => 'eth1', jump => 'ACCEPT', }
      iptables { '998 allow private forward': chain => 'FORWARD', iniface => 'eth1', jump => 'ACCEPT' }
      iptables { '998 allow lo input': chain => 'INPUT', iniface => 'lo', jump => 'ACCEPT', }
      iptables { '998 allow lo forward': chain => 'FORWARD', iniface => 'lo', jump => 'ACCEPT' }
      iptables { '998 allow public established input':
        chain => 'INPUT',
        iniface => 'eth0',
        state => ['ESTABLISHED', 'RELATED'],
        jump => 'ACCEPT',
      }

      # 3.
      iptables { '999 allow base output': chain => 'OUTPUT', jump => 'ACCEPT' }

      # 4.
      iptables { '999 block base input': chain => 'INPUT', jump => 'DROP' }
      iptables { '999 block base forward': chain => 'FORWARD', jump => 'DROP' }
    }
  }
}