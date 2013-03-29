
#############################
#############################
## COMMON NODE DEFINITIONS ##
#############################
#############################


###############
## BASE NODE ##
###############

node basenodecommon {
  # The localconfig module is found in $environment/modules
  include epel
  class { 'localconfig': }
}
