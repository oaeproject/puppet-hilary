# == Class: hilary::install::archive
#
# This class is responsible for deploying the Hilary files via a remote archive
#
# The examples in the parameters below are all based on trying to access a release archive located at:
# https://s3.amazonaws.com/oae-releases/oae-0.2.0/hilary-0.2.0_nodejs-0.8.25.tar.gz
# 
# === Parameters
#
# [*source_parent*]
#   The part of the archive source URI that would come just before the filename (e.g., https://s3.amazonaws.com/oae-releases/oae-0.2.0
#
# [*source_filename*]
# 	The filename portion of the archive without the parent directory URI or the extension (e.g., hilary-0.2.0_nodejs-0.8.25)
#
# [*source_extension*]
#	The extension of the archive, without the filename of the parent directory URI (e.g., tar.gz). Defaults to 'tar.gz'
#
# [*checksum*]
# 	The checksum string of the archive
#
# [*checksum_type*]
# 	The type of checksum (e.g., sha1, md5). Defaults to 'sha1'
#
# [*target_dir*]
# 	The target directory to extract the release archive. Defaults to '/opt/oae'
#
class hilary::install::archive (
	$source_parent,
	$source_filename,
	$source_extension = 'tar.gz',
	$checksum,
	$checksum_type = 'sha1',
	$target_dir = '/opt/oae',) {

	# Download and unpack the archive
	archive { "${source_filename}":
		ensure 			=> present,
		url 			=> "${source_parent}/${source_filename}.${source_extension}",
		target 			=> $target_dir,
		digest_string 	=> $checksum,
		digest_type 	=> $checksum_type,
		extension 		=> $source_extension,
	}
}