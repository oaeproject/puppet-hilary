define ipfilter ($rules = 'null') {

  exec { 'ipf_custom_config_policy':
    command => 'svccfg -s network/ipfilter:default setprop firewall_config_default/policy = astring: custom',
  }

  file { '/etc/ipf/ipf.conf':
    notify  => Service['ipfilter'],
    ensure  => present,
    mode    => '0600',
    content => template('ipfilter/ipf.conf.erb'),
  }

  exec { 'ipf_custom_config_file':
    command => 'svccfg -s network/ipfilter:default setprop firewall_config_default/custom_policy_file = astring: "/etc/ipf/ipf.conf"',
    require => [ Exec['ipf_custom_config_policy'], File['/etc/ipf/ipf.conf'] ]
  }

  service { 'ipfilter':
    ensure  => 'running',
    enable  => true,
    require => Exec['ipf_custom_config_file']
  }
}
