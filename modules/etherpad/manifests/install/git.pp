# == Class: etherpad::install::git
#
# This class is responsible for installing the necessary etherpad files via git and npm.
#
# === Parameters
#
# [*etherpad_dir*]
#   The directory where etherpad should be installed
#
# [*etherpad_git_source*]
#   The full git url where the etherpad-lite source code can be retrieved from.
#   ex: https://github.com/ether/etherpad-lite
#
# [*etherpad_git_revision*]
#   The branch, tag or commit that should be deployed.
#
# [*ep_oae_git_source*]
#   The full git url where the ep_oae plugin source code can be retrieved from.
#   ex: https://github.com/oaeproject/master
#
# [*ep_oae_git_revision*]
#   The branch, tag or commit that should be deployed.
class etherpad::install::git (
        $etherpad_dir,
        $etherpad_git_source,
        $etherpad_git_revision,
        $ep_oae_git_source,
        $ep_oae_git_revision
    ) {

    # Get the etherpad source
    vcsrepo { $etherpad_dir:
        ensure      =>  present,
        provider    =>  git,
        source      =>  $etherpad_git_source,
        revision    =>  $etherpad_git_revision,
    }

    # Install the etherpad npm dependencies
    exec { 'install_etherpad_dependencies':
        command     =>  "${etherpad_dir}/bin/installDeps.sh",
        cwd         =>  $etherpad_dir,
        require     =>  Vcsrepo[$etherpad_dir],
    }

    # Install the OAE etherpad plugin
    vcsrepo { "${etherpad_dir}/node_modules/ep_oae":
        ensure      =>  present,
        provider    =>  git,
        source      =>  $ep_oae_git_source,
        revision    =>  $ep_oae_git_revision,
        require     =>  Exec['install_etherpad_dependencies'],
    }

    # Install the custom CSS for etherpad
    file { "${etherpad_dir}/src/static/custom/pad.css":
        ensure     => present,
        source     => "${etherpad_dir}/node_modules/ep_oae/static/css/pad.css",
        require    => Vcsrepo["${etherpad_dir}/node_modules/ep_oae"],
    }

    # Install the headings plugin
    exec { "install_ep_headings":
        command     => "npm install ep_headings",
        cwd         => $etherpad_dir,
        unless      => "npm ls ep_headings@0.1.6 | grep ep_headings",
        require     => Exec['install_etherpad_dependencies'],
    }

    # Install the spellchecker plugin
    exec { "install_ep_spellcheck":
        command     => "npm install ep_headings",
        cwd         => $etherpad_dir,
        unless      => "npm ls ep_spellcheck@0.0.2 | grep ep_spellcheck",
        require     => Exec['install_etherpad_dependencies'],
    }
}
