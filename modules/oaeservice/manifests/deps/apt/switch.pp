class oaeservice::deps::apt::switch {
    ::apt::key { 'switch.ch':
        key         => '15B76742',
        key_source  => 'http://pkg.switch.ch/switchaai/SWITCHaai-swdistrib.asc',
    }
    ::apt::source { 'switch.ch':
        location    => 'http://pkg.switch.ch/switchaai/ubuntu',
        release     => 'precise',
        repos       => 'main',
        key         => '15B76742',

        # Switch doesn't publish their sources into the apt repository, don't
        # include them or you will get errors when trying to run `apt-get update`
        include_src => false,
    }
}
