# @summary Setup NTP on windows
#
# If your planning on joining a domain you don't need this however there are a
# few cases where windows boxes do not join domains (cloud, dmz, etc). In
# these cases, this profile provides an easy way to set the correct time.
#
# @see https://forge.puppet.com/geoffwilliams/windows_ntp
#
# @example usage
#   include r_profile::windows::ntp
#
# @example Hiera data to use a corporate NTP server
#   r_profile::windows::ntp::server: "ntp.megacorp.com"
#
# @param server NTP server to use. If not specified, defaults to the module's selection
#   (`pool.ntp.org`)
class r_profile::windows::ntp(
    Optional[String] $server = undef,
) {

  class { "windows_ntp":
    server => $server,
  }
}