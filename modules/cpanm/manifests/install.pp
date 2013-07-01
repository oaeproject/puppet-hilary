# This should really be a puppet provider..
class cpanm::install (
        $libraries,
    ){
    # Make sure cpanm gets installed.
    include cpanm

    # Install the library with cpanm
    exec { 'install_cpanm_$library':
        command => inline_template("/usr/local/bin/cpanm <%= (libraries).join(' ') %>"),
        require => Class['cpanm'],
    }
}
