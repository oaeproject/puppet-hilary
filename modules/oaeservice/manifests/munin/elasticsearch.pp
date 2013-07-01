class oaeservice::munin::elasticsearch {

  # Munin needs to be installed before this class can be applied
  require '::oaeservice::munin::client'

  # The elasticsearch munin plugins need some perl love.
  class { '::cpanm::install':
    libraries => ['LWP::UserAgent', 'JSON'],
  }

  # Copy the plugins to the right place.
  file { '/etc/munin/plugins/elasticsearch_cache':
    ensure  => present,
    content => template('munin/plugins/elasticsearch/elasticsearch_cache'),
    mode    => 0777,
  }

  file { '/etc/munin/plugins/elasticsearch_docs':
    ensure  => present,
    content => template('munin/plugins/elasticsearch/elasticsearch_docs'),
    mode    => 0777,
  }
  file { '/etc/munin/plugins/elasticsearch_index_size':
    ensure  => present,
    content => template('munin/plugins/elasticsearch/elasticsearch_index_size'),
    mode    => 0777,
  }
  file { '/etc/munin/plugins/elasticsearch_jvm_memory':
    ensure  => present,
    content => template('munin/plugins/elasticsearch/elasticsearch_jvm_memory'),
    mode    => 0777,
  }
  file { '/etc/munin/plugins/elasticsearch_jvm_threads':
    ensure  => present,
    content => template('munin/plugins/elasticsearch/elasticsearch_jvm_threads'),
    mode    => 0777,
  }
}