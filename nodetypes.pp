node basenode {
  # The localconfig module is found in $environment/modules
  include epel
  class { 'localconfig': }
}

node drivernode inherits basenode {
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

node linuxnode inherits basenode {
  
  ####################
  ## FIREWALL SETUP ##
  ####################
  #
  # By default, allow:
  #
  #   1.  SSH to all nodes
  #   2.  Pings to all nodes
  #   3.  Already-established traffic to continue
  #   4.  Allow everything on private and loopback interfaces
  #   5.  All outgoing traffic
  #
  # By default, deny:
  #
  #   6. All incoming traffic not white-listed above
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
  iptables { '000 allow ssh': chain => 'INPUT', proto => 'tcp', dport => 'ssh', jump => 'ACCEPT', }

  # 2.
  iptables { '998 ping unreachable': chain => 'INPUT', proto => 'icmp', icmp => 'destination-unreachable', jump => 'ACCEPT', }
  iptables { '998 ping quence': chain => 'INPUT', proto => 'icmp', icmp => 'source-quence', jump => 'ACCEPT', }
  iptables { '998 ping exceeded': chain => 'INPUT', proto => 'icmp', icmp => 'time-exceeded', jump => 'ACCEPT', }

  # 3.
  iptables { '998 continue': chain => 'INPUT', state => ['ESTABLISHED', 'RELATED'], jump => 'ACCEPT', }

  # 4.
  iptables { '998 allow private input': chain => 'INPUT', iniface => 'eth1', jump => 'ACCEPT', }
  iptables { '998 allow private forward': chain => 'FORWARD', iniface => 'eth1', jump => 'ACCEPT' }
  iptables { '998 allow lo input': chain => 'INPUT', iniface => 'lo', jump => 'ACCEPT', }
  iptables { '998 allow lo forward': chain => 'FORWARD', iniface => 'lo', jump => 'ACCEPT' }

  # 5.
  iptables { '999 allow base output': chain => 'OUTPUT', jump => 'ACCEPT' }

  # 6.
  iptables { '999 block base input': chain => 'INPUT', jump => 'DROP' }
  iptables { '999 block base forward': chain => 'FORWARD', jump => 'DROP' }

}

node appnode inherits basenode {

  ###########################################
  ## INSTALL HILARY AND 3AKAI-UX CONTAINER ##
  ###########################################

  class { 'hilary':
    app_root_dir        => $localconfig::app_root,
    app_git_user        => $localconfig::app_git_user,
    app_git_branch      => $localconfig::app_git_branch,
    ux_root_dir         => $localconfig::ux_root,
    ux_git_user         => $localconfig::ux_git_user,
    ux_git_branch       => $localconfig::ux_git_branch,
    os_user             => $localconfig::app_user,
    os_group            => $localconfig::app_group,
    upload_files_dir    => $localconfig::app_files,
    require             => Class['nfs']
  }

  class { 'smartos_nfs':
    mountpoint => '/shared',
    server     => $localconfig::nfs_server,
    sourcedir  => $localconfig::nfs_sourcedir,
  }

  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }

}

node activitynode inherits basenode {

  ###########################################
  ## INSTALL HILARY AND 3AKAI-UX CONTAINER ##
  ###########################################

  class { 'hilary':
    app_root_dir        => $localconfig::app_root,
    app_git_user        => $localconfig::app_git_user,
    app_git_branch      => $localconfig::app_git_branch,
    ux_root_dir         => $localconfig::ux_root,
    ux_git_user         => $localconfig::ux_git_user,
    ux_git_branch       => $localconfig::ux_git_branch,
    os_user             => $localconfig::app_user,
    os_group            => $localconfig::app_group,
    upload_files_dir    => $localconfig::app_files,
    enable_activities   => true,
    enable_previews     => false,
  }

  # These don't actually use the shared dir, but the hilary class needs it to exist
  file { '/shared':
    ensure => 'directory',
    before => Class['hilary']
  }

  class { 'ipfilter': }
  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }

}

node ppnode inherits linuxnode {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  package { 'libreoffice':
    ensure  => installed,
  }

  package { 'pdftk':
    ensure  => installed,
  }

  ###########################################
  ## INSTALL HILARY AND 3AKAI-UX CONTAINER ##
  ###########################################

  class { 'hilary':
    app_root_dir        => $localconfig::app_root,
    app_git_user        => $localconfig::app_git_user,
    app_git_branch      => $localconfig::app_git_branch,
    ux_root_dir         => $localconfig::ux_root,
    ux_git_user         => $localconfig::ux_git_user,
    ux_git_branch       => $localconfig::ux_git_branch,
    os_user             => $localconfig::pp_user,
    os_group            => $localconfig::pp_group,
    upload_files_dir    => $localconfig::app_files,
    enable_activities   => false,
    enable_previews     => true,
    provider            => 'apt',
  }

  # These don't actually use the shared dir, but the hilary class needs it to exist
  file { '/shared':
    ensure => 'directory',
    before => Class['hilary']
  }

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node webnode inherits basenode {

  ##################################
  ## INSTALL PACKAGE DEPENDENCIES ##
  ##################################

  package { 'gcc47':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'gmake':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'automake':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'nodejs':
    ensure    => present,
    provider  => pkgin,
  }

  package { 'scmgit':
    ensure    => present,
    provider  => pkgin,
  }

  # git clone http://github.com/sakaiproject/3akai-ux
  vcsrepo { $localconfig::ux_root:
    ensure    => present,
    provider  => git,
    source    => "http://github.com/${localconfig::ux_git_user}/3akai-ux",
    revision  => $localconfig::ux_git_branch,
    require   => Package['scmgit'],
  }

  class { 'nginx':
    internal_app_ips  => $localconfig::app_hosts_internal,
    ux_home           => $localconfig::ux_root,
    ux_admin_host     => $localconfig::ux_admin_host,
    files_home        => $localconfig::app_files,
  }

  class { 'smartos_nfs':
    mountpoint => '/shared',
    server     => $localconfig::nfs_server,
    sourcedir  => $localconfig::nfs_sourcedir,
  }

  class { 'ipfilter':
    rules => [
      'pass in quick on net0 proto tcp from any to any port=80 keep state',
      'pass in quick on net0 proto tcp from any to any port=443 keep state'
    ],
  }

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node dbnode inherits linuxnode {
  # Use devel package so we actually get the JDK..
  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }

  class { 'rsyslog': server_host => $localconfig::rsyslog_host_internal, }
}

node syslognode inherits linuxnode {
  class { 'rsyslog':
    serverOrClient  => 'server',
    server_host => $localconfig::rsyslog_host_internal,
    server_logdir   => $localconfig::rsyslog_server_logdir,
  }
}
