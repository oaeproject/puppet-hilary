class localconfig {

  # OS
  $app_user   = 'admin'
  $app_group  = 'staff'
  $db_user    = 'root'
  $db_group   = 'root' 
  
  # Web servers
  $web_hosts = ['165.225.133.115']
  
  # App servers
  $app_hosts_internal = [
    '10.112.4.121',
    '10.112.4.122',
    '10.112.5.18',
    '10.112.4.244',
    '10.112.6.23',
    '10.112.6.24',
    '10.112.6.25',
    '10.112.6.26'
  ]
  $app_hosts_external = [
    '165.225.133.113',
    '165.225.133.114',
    '165.225.136.163',
    '165.225.136.47',
    '165.225.131.193',
    '165.225.131.3',
    '165.225.132.216',
    '165.225.132.161'
  ]
  
  $circonus_url = 'https://trap.noit.circonus.net/module/httptrap/5655b0c9-5246-68b3-e456-edfb512d4ea1/mys3cr3t'

  # Redis
  $redis_hosts = ['10.112.2.103']

  # Cassandra
  $db_cluster_name = 'Sakai OAE Performance Testing Cluster'
  $db_keyspace = 'oae'
  $db_hosts = [ '10.112.4.124', '10.112.4.125', '10.112.4.126', '10.112.6.27', '10.112.6.28', 10.112.6.29 ]
  $db_initial_tokens = [ '0', '56713727820156410577229101238628035242', '113427455640312821154458202477256070484',
    '28356863910078205288614550619314017621', '85070591730234615865843651857942052864', '141784319550391026443072753096570088106' ]
  $db_timeout = 5000
  $db_replication = 3
  $db_strategyClass = 'SimpleStrategy'

  # Search
  $search_hosts_internal = [{ 'host' => '10.112.4.222', 'port' => 9200 }, { 'host' => '10.112.6.21', 'port' => 9200 } ]
  $search_path_data = '/var/lib/elasticsearch'

  # Messaging
  $mq_hosts_internal = [ { 'host' => '10.112.5.189', 'port' => 5672 } ]

  # Installation details
  $app_service_name = 'node-sakai-oae'
  $app_root = '/opt/oae'
  $app_files = '/shared/files'
  $app_git_user = 'sakaiproject'
  $app_git_branch = 'master'

  $ux_git_user = 'sakaiproject'
  $ux_git_branch = 'Hilary'
  $ux_root = '/opt/3akai-ux'
  $ux_admin_host = 'admin.oae-performance.sakaiproject.org'

  $driver_tsung_version = '1.4.2'

  # Munin regexes
  $munin_allowedRegexes = [
    '^127\.0\.0\.1$',      # local check
    '^10\.112\.3\.104$',   # the loader who has munin-master
    '^75\.102\.43\.87$',   # Circonus - VA-a
    '^75\.102\.43\.88$'    # Circonus - VA-b
  ]
}