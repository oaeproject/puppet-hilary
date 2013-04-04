class elasticsearch (
    $search_hosts,
    $host_address,
    $path_data,
    $version,
    $checksum,
    $host_port        = 9200,
    $max_memory_mb    = 384,
    $min_memory_mb    = 384,
    $rsyslog_enabled  = false,
    $rsyslog_host     = '127.0.0.1') {

  ########################################
  ## DOWNLOAD AND COMPILE ELASTICSEARCH ##
  ########################################

  $filename = "elasticsearch-${version}"
  $url      = "http://download.elasticsearch.org/elasticsearch/elasticsearch/${filename}"

  file { "${path_data}": ensure  => 'directory' }

  archive { 'elasticsearch':
    ensure        => present,
    url           => $url,
    extension     => 'tar.giz',
    target        => '/opt',
    digest_string => $checksum,
    digest_type   => 'sha1',
  }

  exec { 'rename_elasticsearch':
    command => "mv /opt/${filename} /opt/elasticsearch",
    unless  => "test -d /opt/elasticsearch",
    require => Archive['elasticsearch'],
  }

  file { '/etc/init.d/elasticsearch':
    ensure  => present,
    mode    => "0755",
    content => template('elasticsearch/elasticsearch.erb'),
  }

  file { '/opt/elasticsearch/config/elasticsearch.yml':
    ensure  => present,
    content => template('elasticsearch/elasticsearch.yml.erb'),
    require => Exec['rename_elasticsearch'],
  }

  file { '/opt/elasticsearch/config/logging.yml':
    ensure  => present,
    content => template('elasticsearch/logging.yml.erb'),
    require => Exec['rename_elasticsearch'],
  }

  service { 'elasticsearch':
    ensure  => 'running',
    enable  => true,
    require => [ Exec['rename_elasticsearch'], File['/opt/elasticsearch/config/elasticsearch.yml'],
      File['/opt/elasticsearch/config/logging.yml'], File['/etc/init.d/elasticsearch'], File["${path_data}"] ],
  }

}
