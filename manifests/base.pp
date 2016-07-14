class r_profile::base {
  include r_profile::puppet::agent
  include r_profile::motd
  include r_profile::software
  include r_profile::users
  include r_profile::apt
  include "r_profile::base_${downcase($kernel)}"
}
