class oaeservice::opscenter {
    
  ## OpsCenter must be installed w/ oracle java
  require ::oaeservice::deps::package::oraclejava6jre

  class { '::dse::opscenter': }
}