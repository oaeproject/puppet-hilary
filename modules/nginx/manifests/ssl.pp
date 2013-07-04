define nginx::ssl (
    $ssl_crt_source,
    $ssl_crt_path,
    $ssl_key_source,
    $ssl_key_path,
    $ssl_host_dir = $name,) {

    # Ensure the top-level nginx class exists    
    include ::nginx

    # Fetch the nginx owner user from the parent
    $owner = $::nginx::owner
    $group = $::nginx::group

    file { $ssl_host_dir:
        ensure  => directory,
        mode    => 0500,
        owner   => $owner,
        group   => $group,
    }

    file { $ssl_crt_path:
        ensure  => present,
        mode    => 0640,
        owner   => $owner,
        group   => $group,
        source  => $ssl_crt_source,
        require => File[$ssl_host_dir],
    }

    # Private key, when the passphrase is removed, should only be readable by root
    file { $ssl_key_path:
        ensure  => present,
        mode    => 0400,
        owner   => root,
        group   => root,
        source  => $ssl_key_source,
        require => File[$ssl_host_dir],
    }
}