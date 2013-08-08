class oaeservice::deps::package::nodejs ($nodejs_version, $nodegyp_version = '0.9.3') {
  include ::oaeservice::deps::ppa::nodejs
  package { 'nodejs': ensure  => $nodejs_version }
}
