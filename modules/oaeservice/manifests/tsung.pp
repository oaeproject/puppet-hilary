class oaeservice::tsung { 
    include ::oaeservice::deps::package::erlang
    include ::oaeservice::deps::package::gnuplot
    include ::tsung::install::archive

    Class['::oaeservice::deps::package::erlang'] -> Class['::tsung::install::archive']
}