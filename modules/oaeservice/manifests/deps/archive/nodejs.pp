class oaeservice::deps::archive::nodejs {

    # Download and unpack the archive
    archive { "node-v6.10.0":
        ensure          => present,
        url             => 'https://nodejs.org/dist/v6.10.0/node-v6.10.0-linux-x64.tar.gz',
        target          => '/usr/local/node-v6.10.0',
#        digest_url      => $checksum_url,
#        digest_type     => $checksum_type,
        extension       => 'tar.gz',
    }

}

