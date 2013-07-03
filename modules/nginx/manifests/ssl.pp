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

    exec { $ssl_host_dir:
        command => "mkdir ${ssl_host_dir}",
        creates => $ssl_host_dir,
    }

    file { $ssl_crt_path:
        ensure  => present,
        mode    => 0400,
        owner   => $owner,
        group   => $group,
        source  => $ssl_crt_source,
        require => Exec[$ssl_host_dir],
    }

    file { $ssl_key_path:
        ensure  => present,
        mode    => 0400,
        owner   => $owner,
        group   => $group,
        source  => $ssl_key_source,
        require => Exec[$ssl_host_dir],
    }
}