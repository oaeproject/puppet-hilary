class oaeservice::hilary::pp {
    include ::oaeservice::hilary
    include ::oaeservice::deps::pp

    Class['oaeservice::deps::pp']   -> Class['::hilary']
}