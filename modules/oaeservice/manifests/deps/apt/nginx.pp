class oaeservice::deps::apt::nginx {
    ::apt::source { 'nginx':
        location    => 'http://nginx.org/packages/ubuntu/',
        repos       => 'nginx',
        key         => '573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62',
    }
}
