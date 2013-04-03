class oaeservice::deps::package::git {
    case $operatingsystem {
        solaris, Solaris: {
            package { 'scmgit': ensure => present, provider => 'pkgin' }
        }
        default: {
            package { 'git': ensure => present }
        }
    }
}