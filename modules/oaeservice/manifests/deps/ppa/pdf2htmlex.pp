class oaeservice::deps::ppa::pdf2htmlex {
    include apt
    apt::key { 'coolwanglu': key => 'EFB612A8' }
    apt::ppa { 'ppa:coolwanglu/pdf2htmlex': }
}
