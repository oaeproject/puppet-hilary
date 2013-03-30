define elasticsearch (
    $host_address,
    $path_data,
    $host_port      = 9200,
    $max_memory_mb  = 384,
    $min_memory_mb  = 384,
    $version        = '0.20.2') {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }

  ################################
  ## DOWNLOAD AND COMPILE TSUNG ##
  ################################

  $dl_filename          = "elasticsearch-${version}.tar.gz"
  $extracted_foldername = "elasticsearch-${version}"
  $local_filename       = "${dl_filename}"
  $url                  = "http://download.elasticsearch.org/elasticsearch/elasticsearch/${dl_filename}"

  file { "${path_data}":
    ensure  => 'directory',
  }

  exec { "wget ${url}":
    cwd     =>  '/tmp',
    command =>  "/usr/bin/wget ${url} -O ${local_filename}",
    unless  =>  '/usr/bin/test -d /opt/elasticsearch',
    creates =>  "/tmp/${local_filename}",
    timeout =>  0,
  }

  exec { "tar zxvf /tmp/${local_filename}":
    cwd     =>  '/tmp',
    command =>  "/bin/tar -zxvf ${local_filename}",
    unless  =>  '/usr/bin/test -d /opt/elasticsearch',
    require =>  Exec["wget ${url}"],
  }

  exec { "mv ${extracted_foldername} /opt/elasticsearch":
    cwd     =>  '/tmp',
    command =>  "/bin/mv ${extracted_foldername} /opt/elasticsearch",
    unless  =>  '/usr/bin/test -d /opt/elasticsearch',
    creates =>  '/opt/elasticsearch',
    require =>  Exec["tar zxvf /tmp/${local_filename}"],
  }

  file { '/etc/init.d/elasticsearch':
    ensure  => present,
    mode    => "0755",
    content => template('elasticsearch/elasticsearch.erb'),
  }

  file { '/opt/elasticsearch/config/elasticsearch.yml':
    ensure  => present,
    content => template('elasticsearch/elasticsearch.yml.erb'),
    require => Exec["mv ${extracted_foldername} /opt/elasticsearch"],
  }

  file { '/opt/elasticsearch/config/logging.yml':
    ensure  => present,
    content => template('elasticsearch/logging.yml.erb'),
    require => Exec["mv ${extracted_foldername} /opt/elasticsearch"],
  }

  service { 'elasticsearch':
    ensure  => 'running',
    enable  => true,
    require => [ Exec["mv ${extracted_foldername} /opt/elasticsearch"], File['/opt/elasticsearch/config/elasticsearch.yml'],
      File['/opt/elasticsearch/config/logging.yml'], File['/etc/init.d/elasticsearch'], File["${path_data}"] ],
  }

}
