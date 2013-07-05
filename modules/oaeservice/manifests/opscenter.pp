class oaeservice::opscenter {
    include ::oaeservice::deps::package::oraclejava6jre

    Class['::oaeservice::deps::package::oraclejava6jre']  -> Class['::dse::opscenter']

    class { '::dse::opscenter': }
}