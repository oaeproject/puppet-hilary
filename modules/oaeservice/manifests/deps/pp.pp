class oaeservice::deps::pp {
  include oaeservice::deps::common
  include oaeservice::deps::ppa::oae

  # Necessary packages for the preview processor
  $pp_packages = [
    'libreoffice',
    'pdftk',
    'chrpath',
    'libfontconfig1-dev',
    'fonts-international'
  ]
  package { $pp_packages: ensure => installed }

}

