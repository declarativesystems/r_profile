# @summary Select the active system timezone (requires reboot)
#
# Currently supports Linux, Solaris, AIX and Windows.  Timezone names for linux
# need to match the Olsen names available on the current system.  On Linux,
# these are normally found under `/usr/share/zoneinfo`. On Windows the timezone
# needs to match a name from `tzutil -l`
#
# @see https://forge.puppet.com/geoffwilliams/timezone
# @see https://forge.puppet.com/geoffwilliams/windows_timezone
# @see https://en.wikipedia.org/wiki/Tz_database
# @see https://github.com/GeoffWilliams/puppet-windows_timezone/blob/master/doc/windows_timezones.txt
#
# @example Usage
#   include r_profile::timezone
#
# @example Setting the timezone for Linux
#   r_profile::timezone::zone: "Pacific/Honolulu"
#
# @example Setting the timezone for Windows
#   r_profile::timezone::zone: "Hawaiian Standard Time"
#
# @param zone Timezone to set this node to, eg 'Asia/Hong_Kong'
class r_profile::timezone(
    Optional[String] $zone = undef,
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
