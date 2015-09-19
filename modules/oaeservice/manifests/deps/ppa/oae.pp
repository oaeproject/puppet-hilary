class oaeservice::deps::ppa::oae {
    include apt
    apt::key { 'stuart-freeman': key => '13C0BEBC9A6BDCA6E8A1BA94EF88D79652340974' }
    apt::key { 'branden-visser': key => 'D410B2242BFBEFB8CD0D0112120D71BAB77CA805' }
    apt::ppa { 'ppa:oae/deps': }
}
