# R_profile::Timezone
#
# Select the active system timezone (requires reboot).  Currently supports Linux,
# Solaris, AIX and Windows.  Timezone names for linux need to match the Olsen names
# available on the current system.  On Linux, these are normally found under
# `/usr/share/zoneinfo`. On Windows the timezone needs to match a name from `tzutil -l`
#
# Modules required:
#   * geoffwilliams-windows_timezone
#   * geoffwilliams-timezone
#
# @see https://en.wikipedia.org/wiki/Tz_database
#
# @param zone Timezone to set this node to, eg 'Asia/Hong_Kong'
class r_profile::timezone(
  $zone = hiera("r_profile::timezone::zone", undef),
) {

  if $facts['kernel'] == 'windows' {
    class { "windows_timezone":
      tz => $zone,
    }
  } else {
    class { "timezone":
      zone => $zone,
    }
  }
}
