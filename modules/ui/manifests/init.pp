# == Class: ui
#
# This class is responsible for deploying the UI files in the correct location.
#
# === Parameters
#
# [*root_dir*]
#   The directory where the UI files should be put.
#   Defaults to /opt/3akai-ux
#
# [*install_method*]
#   How to install the ui
#
# [*install_config*]
#   A hash containing the install method specific configuration parameters
#
class ui (
    $root_dir               = '/opt/3akai-ux',
    $install_method         = 'git',
    $install_config         = {'source' => 'https://github.com/oaeproject/3akai-ux', 'revision' => 'master'}) {

    class { "::ui::install::${install_method}":
        install_config  => $install_config,
        root_dir        => $root_dir
    }
}
