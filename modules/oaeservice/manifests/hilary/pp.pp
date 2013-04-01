class oaeservice::hilary::pp {

  # Necessary packages for phantomjs and other PP functionality
  $pp_packages = [ 'libreoffice', 'pdftk', 'chrpath', 'libssl-dev', 'libfontconfig1-dev', 'xvfb', 'xfonts-100dpi', 'xfonts-75dpi', 'xfonts-scalable', 'xfonts-cyrillic' ]

  package { $pp_packages: ensure => installed, before => Service['hilary'] }

  include oaeservice::hilary
}