class haproxy ($version, $template, $enabled = true) {
    class { '::haproxy::package': version => $version } ->
    class { '::haproxy::config': template => $template } ->
    class { '::haproxy::service': enabled => $enabled }
}