# R_profiles::Hosts
#
# Ensure that certain hosts entries exist on this host
#
# @param entries Hash of hosts to create - In a form suitable for create_resources
class r_profile::hosts(
  $entries = hiera("r_profile::hosts::entries",false),
) {

  if $entries {
    create_resources("host", $entries)
  }
}
