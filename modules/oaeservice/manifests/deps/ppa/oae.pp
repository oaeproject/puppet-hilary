class oaeservice::deps::ppa::oae {

  include apt
  apt::key { 'stuart-freeman': key => '52340974' }
  apt::key { 'branden-visser': key => 'B77CA805' }
  apt::ppa { 'ppa:oae/deps': }

}
