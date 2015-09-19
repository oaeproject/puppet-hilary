class oaeservice::deps::ppa::gm {
    include apt
    apt::key { 'pteichman': key => '95BFBE33C2B9D4E0978A1C19555CD5CC6159DD90' }
    apt::ppa { 'ppa:pteichman/graphicsmagick': }
}
