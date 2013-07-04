class oaeservice::redis {
    include apt
    apt::source { 'dotdeb':
        location    => 'http://packages.dotdeb.org',
        repos       => 'stable all',
        release     => '',
        key         => '89DF5277',
        key_source  => 'http://www.dotdeb.org/dotdeb.gpg',
        include_src => false,
    }

    class { '::redis': }
}
