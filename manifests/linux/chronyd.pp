# @summary Chronyd (formerly NTPd) support for Linux.
#
# @note No attempt is made to manage this service when running under docker since
# the shared kernel makes this uncessary.
#
# @example Setup cronyd with the default list of servers
#   include r_profile::linux::chronyd
#
# @example Hiera data to list of particular servers
#   r_profile::linux::chronyd::servers:
#     - '0.au.pool.ntp.org'
#     - '1.au.pool.ntp.org'
#
# @param servers List of NTP servers to use
class r_profile::linux::chronyd(
    Array[String] $servers = ["pool.ntp.org"],
) {

  if $facts['virtual'] != "docker" {
    class { 'chronyd':
      servers => $servers,
    }
  }
}