node 'app0' inherits appnode {

  package { 'nodejs':
    ensure    => present,
    provider  => pkgin
  }
  
  vcsrepo { "${localconfig::app_root}":
    ensure    => present,
    provider  => git,
    source    => "http://www.github.com/${localconfig::app_git_user}/Hilary",
    revision  => "${localconfig::app_git_branch}"
  }
}