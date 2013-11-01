class oaeservice::deps::pp {
  include oaeservice::deps::common
  include oaeservice::deps::ppa::oae
  include oaeservice::deps::ppa::pdf2htmlex

  # Necessary packages for the preview processor
  $pp_packages = [
    'libreoffice',
    'pdftk',
    'chrpath',
    'libfontconfig1-dev',
    'fonts-international',
    'pdf2htmlex'
  ]
  package { $pp_packages: ensure => installed }
}
