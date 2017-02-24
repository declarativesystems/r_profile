# R_profile::Timezone
#
# Select the active system timezone (requires reboot).  Currently supports Linux,
# Solaris and AIX.  Timezone names need to match the Olsen names available on the
# current system.  On Linux, these are normally found under `/usr/share/zoneinfo`
# @see https://en.wikipedia.org/wiki/Tz_database
#
# @param zone Timezone to set this node to, eg 'Asia/Hong_Kong'
class r_profile::timezone(
  $zone = hiera("r_profile::timezone::zone", undef),
) {

  class { "timezone":
    zone => $zone,
  }
}
