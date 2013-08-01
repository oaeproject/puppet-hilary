class ui::install::apt ($install_config, $root_dir = '/opt/3akai-ux') {
    package { '3akai-ux':
        ensure => $install_config['version'],
    }   
}
