class oaeservice::deps::package::python {
    package { 'python-pip': ensure => installed }
    package { 'python-dev': ensure => installed }
}
