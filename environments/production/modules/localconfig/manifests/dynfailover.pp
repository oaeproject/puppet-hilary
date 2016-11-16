class localconfig::dynfailover {

    $dynamichost = hiera('dynamichost')
    $dynapiuser  = hiera('dynapiuser')
    $dynapipass  = hiera('dynapipass')
    $dynfailovertimeout = hiera('dynfailovertimeout')
    $web0ip = hiera('web0ip')
    $web1ip = hiera('web1ip')
    $app_admin_tenant = hiera('app_admin_tenant')
    $web_domain = hiera('web_domain')

    file { 'dyn_failover':
        path    => "/usr/local/bin/dyn_failover",
        mode    => 0755,
        content => template('localconfig/dyn_failover.erb')
    }

    cron { 'dynfailover':
        ensure  => present,
        command => "/usr/local/bin/dyn_failover",
        user    => 'root',
        target  => 'root',
        minute  => '*'
    }
}

