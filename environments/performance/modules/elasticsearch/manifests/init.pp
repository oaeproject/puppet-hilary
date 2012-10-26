    $host_address,
    $host_port     = 9200,
    $max_memory_mb = 384,
    $min_memory_mb = 384,
    $version       = '0.20.0.RC1') {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################

  package { 'java-1.6.0-openjdk-devel':
    ensure  => installed,
  }

  ################################
  ## DOWNLOAD AND COMPILE TSUNG ##
  ################################

  $foldername = "elasticsearch-${version}"
  $filename   = "${foldername}.tar.gz"
  $url        = "https://github.com/downloads/elasticsearch/elasticsearch/${filename}"

  exec { "wget ${url}":
    cwd     =>  '/tmp',
    command =>  "/usr/bin/wget ${url}",
    unless  =>  '/usr/bin/test -d /opt/elasticsearch',
    creates =>  '/tmp/${filename}',
  }
  
  exec { "tar zxvf /tmp/${filename}":
    cwd     =>  '/tmp',
    command =>  "/bin/tar -zxvf ${filename}",
    unless  =>  '/usr/bin/test -d /opt/elasticsearch',
    require =>  Exec["wget ${url}"],
  }
  
  exec { "mv ${foldername} /opt/elasticsearch":
    cwd     =>  '/tmp',
    command =>  "/bin/mv ${foldername} /opt/elasticsearch",
    unless  =>  '/usr/bin/test -d /opt/elasticsearch',
    creates =>  '/opt/elasticsearch',
    require =>  Exec["tar zxvf /tmp/${filename}"],
  }

  file { '/etc/init.d/elasticsearch':
    ensure  => present,
    mode    => 0755,
    content => template('elasticsearch/elasticsearch.erb'),
    notify  => Service['elasticsearch'],
  }

  file { '/opt/elasticsearch/config/elasticsearch.yml':
    ensure  => present,
    content => template('elasticsearch/elasticsearch.yml.erb'),
    require => Exec["mv ${foldername} /opt/elasticsearch"],
    notify  => Service['elasticsearch'],
  }

  service { 'elasticsearch':
    ensure  => 'running',
    enable  => 'true',
    require => [ Exec["mv ${foldername} /opt/elasticsearch"], File['/opt/elasticsearch/config/elasticsearch.yml'] ],
  }

}
