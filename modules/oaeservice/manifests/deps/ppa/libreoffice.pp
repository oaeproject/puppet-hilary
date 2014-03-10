class oaeservice::deps::ppa::libreoffice {
    include apt
    apt::key { 'ricotz': key => '9270E723' }
    apt::ppa { 'ppa:libreoffice/libreoffice-4-2': }
}
