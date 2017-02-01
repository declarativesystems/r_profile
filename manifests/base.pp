# R_profile::Base
#
# A generic 'baseleve' style class 
class r_profile::base {
  include r_profile::motd
  include r_profile::software
  include r_profile::users
  include "r_profile::${downcase($kernel)}::base"
  include r_profile::monitor::nagios_monitored
}
