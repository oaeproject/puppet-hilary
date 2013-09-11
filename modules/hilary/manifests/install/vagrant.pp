class hilary::install::vagrant ($install_config, $app_root_dir = '/opt/oae') {
    require ::oaeservice::deps::package::nodejs

    # npm install -d
    exec { "npm_install_dependencies":
        cwd         => $app_root_dir,

        # Forcing CFLAGS for std=c99 for hiredis, until https://github.com/pietern/hiredis-node/pull/33 is resolved
        environment => ['CFLAGS="-std=c99"', 'HOME=/root'],
        command     => 'npm install -d',
        logoutput   => 'on_failure',
    }
}
