
#############################
#############################
## COMMON NODE DEFINITIONS ##
#############################
#############################


###############
## BASE NODE ##
###############

node basenode {
  # The localconfig module is found in $environment/modules
  include epel
  class { 'localconfig': }
}
