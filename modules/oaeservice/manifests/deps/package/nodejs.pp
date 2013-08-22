class oaeservice::deps::package::nodejs ($nodejs_version) {
  include ::oaeservice::deps::ppa::nodejs
  package { 'nodejs': ensure  => $nodejs_version }
}
