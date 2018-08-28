# @summary NTP for Linux/unix based servers.
#
# @note Newer Linux systems should use `r_profile::linux::chronyd`
#
# Windows users gain NTP by joining a domain. There is no support for standalone windows NTP yet
#
# Supports:
# * AIX
# * Solaris
# * Linux
#
# @see https://forge.puppet.com/puppetlabs/ntp
#
# @example setup default NTP client
#   include r_profile::ntp
#
# @example Hiera data for setting the server(s) to use
#   r_profile::ntp::servers:
#     - time.windows.com
#     - pool.ntp.org
#
# @example Hiera data to prevent trying to manage the package
#   r_profile::ntp::package_manage: false
#
# @example Hiera data to prevent trying to manage the service
#   r_profile::ntp::service_manage: false
#
# @param servers Array of servers to ask for the time
# @param package_manage True if we should install ntp otherwise false
# @param service_manage True if we should control the ntpd service otherwise false
class r_profile::ntp(
    Optional[Array[String]] $servers        = undef,
    Optional[Boolean]       $package_manage = undef,
    Optional[Boolean]       $service_manage = undef,
) {
  if $facts['virtual'] != "docker" {
    class { "ntp":
      servers        => $servers,
      package_manage => $package_manage,
      service_manage => $service_manage,
    }
  }
}
