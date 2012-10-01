node 'app0' inherits appnode {
  
  package { 'gcc-compiler':
    ensure   => present,
    provider => pkgin,
  }

}