# R_profiles::Host
#
# Mange the static lookup table for hostnames.
#
# We take both a `base` and override hash of services and merge them to form a final list. This allows for simpler
# management through hiera.
#
# @example Basic usage
#   include r_profile::host
#
# @example Purging unmanaged entries
#   r_profile::host::purge: true
#
# @example Adding a host record
#   r_profile::host::hosts:
#     localhost.localdomain
#       ip: 127.0.0.1
#       host_aliases: localhost
#
# @param base_hosts Base hash of hosts to create, see examples
# @param hosts Override hash of hosts to create, see examples
# @param purge `true` to purge unmanaged host entries, otherwise `false`
class r_profile::host(
  Hash[String,Hash] $base_hosts = {},
  Hash[String,Hash] $hosts      = {},
  Boolean           $purge      = false,
) {

  resources { "host":
    purge => $purge,
  }

  ($base_hosts + $hosts).each |$key, $opts| {
    host {
      default:
        ensure => present,
      ;
      $key:
        * => $opts,
    }
  }
}
