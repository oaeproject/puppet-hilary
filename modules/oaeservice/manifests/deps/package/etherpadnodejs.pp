class oaeservice::deps::package::etherpadnodejs ($nodejs_version) {
  include ::oaeservice::deps::ppa::nodejs
  package { 'nodejs': ensure  => $nodejs_version }
}
