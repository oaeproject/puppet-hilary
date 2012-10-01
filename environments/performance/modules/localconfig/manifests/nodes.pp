node 'app0' inherits appnode {

  package { 'nodejs':
    ensure    => present,
    provider  => pkgin,
  }
  
  package { 'scmgit':
    ensure    => present,
    provider  => pkgin,
  }
  
  vcsrepo { "${localconfig::app_root}":
    ensure    => present,
    provider  => git,
    source    => "http://www.github.com/${localconfig::app_git_user}/Hilary",
    revision  => "${localconfig::app_git_branch}",
    require   => Package['scmgit'],
  }
  
  exec { "chown_${localconfig::app_root}":
    command => "/opt/local/bin/chown -R ${localconfig::user}:${localconfig::group} ${localconfig::app_root}",
    require => Vcsrepo["${localconfig::app_root}"],
  }
  
  file { "${localconfig::app_root}/config.js":
    ensure  => present,
    content => template('localconfig/config.js.erb'),
  }

}