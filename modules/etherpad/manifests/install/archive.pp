# == Class: etherpad::install::archive
#
# This class is responsible for installing the necessary etherpad files from a remote archive. It expects that there will be
# both a package and a checksum available at a remote URL.
#
# The checksum URL should be located at <package url including extension>.<checksum_type>.txt
#
# === Parameters
#
# [*install_config['url_base']*]
#   The part of the archive source URI that would come just before the minor version directory (e.g., https://s3.amazonaws.com/oae-releases/etherpad)
#
# [*install_config['url_extension']*]
#   The extension of the archive, without the filename of the parent directory URI (e.g., tar.gz). Defaults to 'tar.gz'
#
# [*install_config['version_major_minor']*]
#   The major and minor version of the package in the format: "<major>.<minor>" (e.g., 1.2)
#   The filename portion of the archive without the parent directory URI or the extension (e.g., etherpad-1.2.91_nodejs-0.10.15)
#
# [*install_config['version_patch']*]
#   The patch version of the package (e.g., 0 or 2-<# of commits since tag>-<commit hash>)
#
# [*install_config['version_nodejs']*]
#   The nodejs version with which this package was prepared (e.g., 0.10.15)
#
# [*install_config['checksum_type']*]
#   The type of checksum (e.g., sha1, md5). Defaults to 'sha1'
#
# [*etherpad_root_dir*]
#   The target directory to extract the release archive. Defaults to '/opt/etherpad'
#
class etherpad::install::archive ($install_config, $etherpad_root_dir = '/opt/etherpad') {

    $_install_config = merge({
        'url_extension' => 'tar.gz',
        'checksum_type' => 'sha1'
    }, $install_config)

    $url_base               = $_install_config['url_base']
    $url_extension          = $_install_config['url_extension']
    $version_major_minor    = $_install_config['version_major_minor']
    $version_patch          = $_install_config['version_patch']
    $version_nodejs         = $_install_config['version_nodejs']
    $checksum_type          = $_install_config['checksum_type']

    $url_filename = "etherpad-${version_major_minor}.${version_patch}_nodejs-${version_nodejs}.${url_extension}"
    $package_url = "${url_base}/${version_major_minor}/${url_filename}"
    $checksum_url = "${package_url}.${checksum_type}.txt"

    # Download and unpack the archive
    archive { "${url_filename}":
        ensure          => present,
        url             => $package_url,
        target          => $etherpad_root_dir,
        digest_url      => $checksum_url,
        digest_type     => $checksum_type,
        extension       => $url_extension,
    }
}