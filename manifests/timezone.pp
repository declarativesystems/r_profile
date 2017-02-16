# R_profile::Timezone
#
# Select the active system timezone (requires reboot).  Currently supports Linux,
# Solaris and AIX
#
# @param zone Timezone to set this node to, eg 'Asia/Hong_Kong'
class r_profile::timezone(
  $zone = hiera("r_profile::timezone::zone", undef),
) {

  class { "timezone":
    zone => $zone,
  }
}
