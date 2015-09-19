class oaeservice::deps::ppa::nodejs {
    include apt
    apt::key { 'chris-lea': key => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30' }
    apt::ppa { 'ppa:chris-lea/node.js': }
    apt::ppa { 'ppa:chris-lea/node.js-legacy': }
}
