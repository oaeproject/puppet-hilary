class localconfig {

  # OS
  $app_user   = 'admin'
  $app_group  = 'staff'
  $db_user    = 'root'
  $db_group   = 'root' 
  
  # Web servers
  $web_hosts = ['165.225.133.115']
  
  # App servers
  $app_hosts_internal = ['10.112.4.121', '10.112.4.122']
  $app_hosts_external = ['165.225.133.113', '165.225.133.114']

  # Redis
  $redis_hosts = [$app_hosts[0]]

  # Cassandra
  $db_cluster_name = 'Sakai OAE Performance Testing Cluster'
  $db_keyspace = 'oae'
  $db_hosts = [ '10.112.4.124', '10.112.4.125', '10.112.4.126' ]
  $db_timeout = 5000
  $db_replication = 1
  $db_strategyClass = 'SimpleStrategy'

  # Install details
  $app_root = '/opt/oae'
  $app_git_user = 'sakaiproject'
  $app_git_branch = 'master'

}