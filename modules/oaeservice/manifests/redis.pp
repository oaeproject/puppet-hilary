class oaeservice::redis {
    include apt
    include oaeservice::deps::ppa::oae

    class { '::redis': }
}
