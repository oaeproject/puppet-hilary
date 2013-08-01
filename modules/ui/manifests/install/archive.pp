# == Class: ui::install::archive
#
# This class is responsible for deploying the UI files via a remote archive
#
# The examples in the parameters below are all based on trying to access a release archive located at:
# https://s3.amazonaws.com/oae-releases/oae-0.2.0/3akai-ux-0.2.0.tar.gz
# 
# === Parameters
#
# [*install_config['url_parent']*]
#   The part of the archive source URI that would come just before the filename (e.g., https://s3.amazonaws.com/oae-releases/oae-0.2.0
#
# [*install_config['url_filename']*]
#   The filename portion of the archive without the parent directory URI or the extension (e.g., 3akai-ux-0.2.0)
#
# [*install_config['url_extension']*]
#   The extension of the archive, without the filename of the parent directory URI (e.g., tar.gz). Defaults to 'tar.gz'
#
# [*install_config['checksum']*]
#   The checksum string of the archive
#
# [*install_config['checksum_type']*]
#   The type of checksum (e.g., sha1, md5). Defaults to 'sha1'
#
# [*app_root_dir*]
#   The target directory to extract the release archive. Defaults to '/opt/3akai-ux'
#
class ui::install::archive ($install_config, $root_dir = '/opt/3akai-ux') {

    $_install_config = merge({
        'url_extension' => 'tar.gz',
        'checksum_type' => 'sha1'
    }, $install_config)

    $url_parent     = $_install_config['url_parent']
    $url_filename   = $_install_config['url_filename']
    $url_extension  = $_install_config['url_extension']
    $checksum       = $_install_config['checksum']
    $checksum_type  = $_install_config['checksum_type']

    # Download and unpack the archive
    archive { "${url_filename}":
        ensure          => present,
        url             => "${url_parent}/${url_filename}.${url_extension}",
        target          => $root_dir,
        digest_string   => $checksum,
        digest_type     => $checksum_type,
        extension       => $url_extension,
    }
}
