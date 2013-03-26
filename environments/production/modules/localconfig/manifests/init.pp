class localconfig {

  # OS
  $app_user   = 'admin'
  $app_group  = 'staff'
  $db_user    = 'root'
  $db_group   = 'root'
  $pp_user    = 'root'
  $pp_group   = 'root'

  # Web servers
  $web_hosts = ['10.224.14.16']

  # App servers
  $app_hosts_internal = ['10.224.14.27']
  $app_hosts_external = ['37.153.96.213']

  $circonus_url = 'https://trap.noit.circonus.net/module/httptrap/5655b0c9-5246-68b3-e456-edfb512d4ea1/mys3cr3t'

  # Redis -- List the master first (at index 0)
  $redis_hosts = ['10.224.14.14']

  # Activity redis -- List the master first (at index 0)
  $activity_redis_hosts = ['10.224.14.12']

  # Cassandra
  $db_cluster_name = 'Sakai OAE Production Cluster'
  $db_keyspace = 'oae'
  $db_hosts = ['10.224.14.28']
  $db_initial_tokens = [ '0', '56713727820156410577229101238628035242', '113427455640312821154458202477256070484' ]
  $db_timeout = 5000
  $db_replication = 1
  $db_strategyClass = 'SimpleStrategy'

  # Search
  $search_hosts_internal = [{ 'host' => '10.224.14.36', 'port' => 9200 }]
  $search_path_data = '/var/lib/elasticsearch'

  # Messaging
  $mq_hosts_internal = [ { 'host' => '10.224.14.35', 'port' => 5672 } ]

  # RSyslog
  $rsyslog_host_internal = '10.224.14.32'
  $rsyslog_server_logdir = '/var/log/rsyslog'

  # Installation details
  $app_root = '/opt/oae'
  $app_files = '/shared/files'
  $app_git_user = 'sakaiproject'
  $app_git_branch = 'master'

  $ux_git_user = 'sakaiproject'
  $ux_git_branch = 'Hilary'
  $ux_root = '/opt/3akai-ux'
  $ux_admin_host = 'admin.oae-production.sakaiproject.org'

  # Munin regexes
  $munin_allowedRegexes = [
    '^127\.0\.0\.1$',      # local check
    '^10\.112\.3\.104$',   # the loader who has munin-master
    '^75\.102\.43\.87$',   # Circonus - VA-a
    '^75\.102\.43\.88$'    # Circonus - VA-b
  ]

  # Files NFS Storage
  $files_nfs_server = '10.224.14.126'
  $files_nfs_sourcedir = '/zones/nfs/a906ce30-37bb-480c-98a5-794981b27e01/sakai1'
}
