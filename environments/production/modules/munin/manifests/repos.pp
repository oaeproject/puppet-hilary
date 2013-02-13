class munin::repos {
    
  $release = $operatingsystem ? {
      /CentOS|RedHat/ => $lsbmajdistrelease,
      /Amazon|Linux/ => '6'
  }

  yumrepo { "epel":
    name     =>  "epel",
    baseurl  => "http://ftp.riken.jp/Linux/fedora/epel/$releasever/$basearch/",
    enabled  => '1',
    gpgcheck => '0',
  }
  
  file { "/etc/yum.repos.d/epel.repo":
    ensure  => present,
    mode    => 0644,
    owner   => "root",
    require => Yumrepo["epel"]
  }
}