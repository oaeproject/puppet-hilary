class ui::install::git ($install_config, $root_dir = '/opt/3akai-ux') {
    require ::oaeservice::deps::package::git

    $_install_config = merge({
        'source'    => 'https://github.com/oaeproject/3akai-ux',
        'revision'  => 'master'
    }, $install_config)

    vcsrepo { $root_dir:
        ensure    => latest,
        provider  => git,
        source    => $_install_config['source'],
        revision  => $_install_config['revision'],
    }
}