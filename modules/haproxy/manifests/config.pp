class haproxy::config ($template) {
    file { '/etc/haproxy/haproxy.cfg': content => template($template) }
}