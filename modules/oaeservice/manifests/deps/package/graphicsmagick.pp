class oaeservice::deps::package::graphicsmagick {
    include ::oaeservice::deps::ppa::gm

    package { 'graphicsmagick':
        ensure => '1.3.16-1.1ubuntu1ppa1~precise'
    }
}
