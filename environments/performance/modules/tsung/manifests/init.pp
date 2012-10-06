class tsung (version = '1.4.2') {

  ##########################
  ## PACKAGE DEPENDENCIES ##
  ##########################
  
  package { 'gcc47':
    ensure    => present,
    provider  => pkgin,
  }
  
  package { 'gmake':
    ensure    => present,
    provider  => pkgin,
  }
  
  package { 'automake':
    ensure    => present,
    provider  => pkgin,
  }
  
  package { 'erlang':
    ensure    => present,
    provider  => 'pkgin',
  }
  
  ################################
  ## DOWNLOAD AND COMPILE TSUNG ##
  ################################

  $foldername = "tsung-${version}"
  $filename   = "${foldername}.tar.gz"
  $url        = "http://tsung.erlang-projects.org/dist/${filename}"

  exec { "wget ${url}":
    cwd     =>  '/tmp',
    command =>  "wget ${url}",
    unless  =>  'test -f /opt/local/bin/tsung',
    creates =>  '/tmp/${filename}',
    require => [ Package['gcc47'], Package['gmake'], Package['automake'],
        Package['erlang'] ],
  }
  
  exec { "tar zxvf ${filename}":
    cwd     =>  '/tmp',
    command =>  "tar -zxvf ${filename}",
    unless  =>  'test -f /opt/local/bin/tsung',
    require =>  Exec["wget ${url}"],
  }
  
  exec { "make /tmp/${foldername}":
    cwd     =>  "/tmp/${foldername}",
    command =>  '/opt/local/gnu/bin/make && make install',
    unless  =>  'test -f /opt/local/bin/tsung',
    require =>  Exec["tar zxvf ${filename}"],
  }

}