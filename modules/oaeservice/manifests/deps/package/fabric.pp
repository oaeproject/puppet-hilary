class oaeservice::deps::package::fabric {
    require oaeservice::deps::package::python
    package { 'fabric': ensure => 'installed', provider => 'pip' }
}