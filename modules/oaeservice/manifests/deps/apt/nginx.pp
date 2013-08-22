class oaeservice::deps::apt::nginx {
    ::apt::source { 'nginx':
        location    => 'http://nginx.org/packages/ubuntu/',
        repos       => 'nginx',
        key         => 'ABF5BD827BD9BF62',
    }
}
