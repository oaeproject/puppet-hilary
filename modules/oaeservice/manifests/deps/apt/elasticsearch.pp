class oaeservice::deps::apt::elasticsearch {
    ::apt::source { 'elasticsearch':
        location    => 'http://packages.elasticsearch.org/elasticsearch/1.1/debian',
        repos       => 'main',
        key         => 'D88E42B4',
    }
}
