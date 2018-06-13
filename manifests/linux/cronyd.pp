# R_profile::Linux::Chronyd
#
# Cronyd (formerly NTPd) support for Linux
#
# @see https://forge.puppet.com/beergeek/chronyd
#
# @example Setup cronyd with the default list of servers
#   include r_profile::linux::cronyd
#
# @example Hiera data to list of particular servers
#   r_profile::linux::cronyd::servers:
#     - '0.au.pool.ntp.org'
#     - '1.au.pool.ntp.org'
#
# @param servers List of NTP servers to use
class r_profile::linux::cronyd(
    Array[String] $servers = ["pool.ntp.org"],
) {
  class { 'chronyd':
    servers => $servers,
  }
}