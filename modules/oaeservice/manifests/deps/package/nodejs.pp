class oaeservice::deps::package::nodejs ($nodejs_version) {
  include ::oaeservice::deps::ppa::oae
  package { 'nodejs': ensure  => $nodejs_version }
}
