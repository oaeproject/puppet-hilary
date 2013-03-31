class oaeservice::hilary::pp {
  include oaeservice::hilary

  package { 'libreoffice': ensure => installed, before => Class['hilary'] }
  package { 'pdftk': ensure => installed, before => Class['hilary'] }
}