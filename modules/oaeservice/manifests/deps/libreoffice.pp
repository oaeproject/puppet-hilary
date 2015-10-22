class oaeservice::deps::pp {
    include oaeservice::deps::ppa::oae

    # Install the correct version of libreoffice
    package {'libreoffice':
        ensure   => '1:4.3.0-0ubuntu1~precise1'
    }
}
