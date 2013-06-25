class etherpad::install (
        $etherpad_dir            = '/opt/etherpad',
        $install_method          = 'package',
        $package_name            = 'etherpad-lite',
        $package_version         = '1.2.91-4',
        $etherpad_git_revision   = '1.2.91',
        $ep_oae_git_revision     = 'master'
    ){

    case $install_method {
        'git': {
            # Get the etherpad source
            vcsrepo { $etherpad_dir:
                ensure      =>  present,
                provider    =>  git,
                source      =>  'https://github.com/ether/etherpad-lite',
                revision    =>  $etherpad_git_revision,
            }

            # Install the etherpad npm dependencies
            exec { 'install_etherpad_dependencies':
                command     =>  "${$etherpad_dir}/bin/installDeps.sh",
                cwd         =>  $etherpad_dir,
                require     =>  Vcsrepo[$etherpad_dir],
            }

            # Install the OAE etherpad plugin
            vcsrepo { "${etherpad_dir}/node_modules/ep_oae":
                ensure      =>  present,
                provider    =>  git,
                source      =>  'https://github.com/oaeproject/ep_oae',
                revision    =>  $ep_oae_git_revision,
                require     =>  Exec['install_etherpad_dependencies'],
            }

            # Install the custom CSS for etherpad
            file { "$etherpad_dir/src/static/custom/pad.css":
                ensure     => present,
                source     => "${etherpad_dir}/node_modules/ep_oae/static/css/pad.css",
                require    => Vcsrepo["${etherpad_dir}/node_modules/ep_oae"],
            }

            # Install the ep_headings plugin
            exec { "install_ep_headings":
                command     => "npm install ep_headings",
                cwd         => $etherpad_dir,
                require     => Exec['install_etherpad_dependencies'],
            }
        }
        'package': {
            # When using a packaged deploy we only need to install the package.
            # The package will contain all the node modules.
            package { $package_name:
                ensure => $package_version,
            }
        }
    }
}
