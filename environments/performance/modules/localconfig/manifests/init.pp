class localconfig {

  # OS
  $app_user   = 'admin'
  $app_group  = 'staff'
  $db_user    = 'root'
  $db_group   = 'root' 
  
  # App servers
  $app_hosts = ['165.225.130.148']

  # Redis
  $redis_hosts = [$app_hosts[0]]
  
  # Cassandra
  $db_cluster_name = 'Sakai OAE Performance Testing Cluster'
  $db_keyspace = 'oae'
  $db_hosts = [ '10.112.2.10', '10.112.4.67', '10.112.4.83' ]
  $db_timeout = 5000
  $db_replication = 1
  $db_strategyClass = 'SimpleStrategy'

  # Install details
  $app_root = '/opt/oae'
  $app_git_user = 'sakaiproject'
  $app_git_branch = 'master'

}