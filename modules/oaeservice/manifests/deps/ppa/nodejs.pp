class oaeservice::deps::ppa::nodejs {
    include apt
    apt::key { 'chris-lea': key => '4BD6EC30' }
    apt::ppa { 'ppa:chris-lea/node.js': }
    apt::ppa { 'ppa:chris-lea/node.js-legacy': }
}
