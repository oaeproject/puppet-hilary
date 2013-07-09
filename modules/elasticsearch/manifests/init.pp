class elasticsearch (
    $search_hosts,
    $host_address,
    $path_data,
    $version,
    $checksum,
    $host_port        = 9200,
    $heap_size_mb     = 384,
    $heap_newsize_mb  = false,
    $rsyslog_enabled  = false,
    $rsyslog_host     = '127.0.0.1') {

  $filename = "elasticsearch-${version}.deb"

  ########################################
  ## DOWNLOAD AND COMPILE ELASTICSEARCH ##
  ########################################

  # Ensure the data directory exists
  exec { 'mkdir_data':
    command   => "mkdir -p ${path_data}",
    unless    => "test -d ${path_data}",
  }

  archive::download { $filename:
    url           => "https://download.elasticsearch.org/elasticsearch/elasticsearch/${filename}",
    digest_string => $checksum,
    digest_type   => 'sha1',
    src_target    => '/usr/src'
  }

  package { 'elasticsearch':
    ensure    => installed,
    provider  => dpkg,
    source    => "/usr/src/${filename}",
    require   => Archive::Download[$filename]
  }

  file { '/etc/init.d/elasticsearch':
    ensure  => present,
    mode    => '0755',
    content => template('elasticsearch/elasticsearch.erb'),
    require => Package['elasticsearch']
  }

  file { '/etc/elasticsearch/elasticsearch.yml':
    ensure  => present,
    content => template('elasticsearch/elasticsearch.yml.erb'),
    require => Package['elasticsearch'],
  }

  file { '/etc/elasticsearch/logging.yml':
    ensure  => present,
    content => template('elasticsearch/logging.yml.erb'),
    require => Package['elasticsearch'],
  }

  service { 'elasticsearch':
    ensure  => 'running',
    enable  => true,
    require => [ Package['elasticsearch'], File['/etc/elasticsearch/elasticsearch.yml'],
      File['/etc/elasticsearch/logging.yml'], File['/etc/init.d/elasticsearch'], Exec['mkdir_data'] ],
  }

}
