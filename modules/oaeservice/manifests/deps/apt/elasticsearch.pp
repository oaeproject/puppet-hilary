class oaeservice::deps::apt::elasticsearch {
    ::apt::source { 'elasticsearch':
        location    => 'http://packages.elasticsearch.org/elasticsearch/1.1/debian',
        release     => 'stable',
        repos       => 'main',
        key         => 'D88E42B4',

        # Elasticsearch doesn't publish their sources into the apt repository, don't
        # include them or you will get errors when trying to run `apt-get update`
        include_src => false,
    }
}
