class oaeservice::deps::package::git {
    case $operatingsystem {
        solaris, Solaris: {
            package { 'scmgit': ensure => installed, provider => 'pkgin' }
        }
        default: {
            package { 'git': ensure => installed }
        }
    }
}