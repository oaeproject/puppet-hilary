class localconfig {

  # OS
  $app_user   = 'admin'
  $app_group  = 'staff'
  $db_user    = 'root'
  $db_group   = 'root'
  $pp_user    = 'root'
  $pp_group   = 'root'

  # Web servers
  $web_hosts = ['165.225.138.197']

  # App servers
  $app_hosts_internal = [
    '10.112.5.119',
    '10.112.6.140',
    '10.112.2.120',
    '10.112.6.226',
  ]

  $app_sign_key = 'A;SLDFJ984FJW398FJWP4GO5IJSLRTKGJ'

  $cookie_secret = 'SODIFJ984FJA984JAFP98WF4PAW984F984FJ9'

  $circonus_url = 'https://trap.noit.circonus.net/module/httptrap/5655b0c9-5246-68b3-e456-edfb512d4ea1/mys3cr3t'

  # Redis
  $redis_hosts = ['10.112.3.244']

  # ActivityRedis
  $activity_redis_hosts = ['10.112.1.54']

  # Cassandra
  $db_cluster_name = 'Sakai OAE Performance Testing Cluster'
  $db_keyspace = 'oae'
  $db_hosts = [ '10.112.1.114', '10.112.6.110', '10.112.5.200' ]
  $db_initial_tokens = [ '0', '56713727820156410577229101238628035242', '113427455640312821154458202477256070484' ]
  $db_timeout = 5000
  $db_replication = 3
  $db_strategyClass = 'SimpleStrategy'

  # Search
  $search_hosts_internal = [
    { 'host' => '10.112.6.231', 'port' => 9200 },
    { 'host' => '10.112.3.83', 'port' => 9200 },
  ]
  $search_path_data = '/var/lib/elasticsearch'
  $search_memory_mb = 3072

  # Messaging
  $mq_hosts_internal = [ { 'host' => '10.112.6.254', 'port' => 5672 } ]

  # Installation details
  $app_root = '/opt/oae'
  $app_files_parent = '/shared'
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

  # NFS
  $files_nfs_server = '10.112.0.6'
  $files_nfs_sourcedir = '/vol/joya62690cd_e032_45fc_84d8_c063dd34bcf0'

  # Etherpad
  # TODO: Change these to the dedicated machines rather than the app servers.
  $etherpad_hosts_internal = [
    '10.112.5.18',
    '10.112.4.244',
  ]
  $etherpad_session_key     = 'YzI3znrSsxByU1QsRtPZhX6tkxVUoQh1suIDrUcBtewrsBDLPkGRTP6oUqhL'
  $etherpad_api_key         = 'JgKlWx5YL5OeksEC1zJZTOiTVb5dDe2RiBdCDs9ZmcEazS2E4tHsH52ANvuuxuWpsETV6sX2hhFP83pgtKPzJRUEhoZaDsPsHwMq'
  $etherpad_domain_suffix   = '.etherpad.oae-performance.sakaiproject.org'
}
