# R_profile::Linux::Resolv_conf
#
# Manage `/etc/resolv.conf`
#
# @see https://forge.puppet.com/geoffwilliams/resolv_conf
#
# @example basic usage
#   include r_profile::linux::resolv_conf
#
# @example Hiera data
#   r_profile::linux::resolv_conf::settings:
#     search: "megalan megacorp.com",
#     nameservers:
#       - "10.0.0.1"
#       - "10.0.4.4"
#
# @param base_settings Base hash of settings to pass to `resolv_conf` class (see examples)
# @param settings Override hash of settings to pass to `resolv_conf` class (see examples)
class r_profile::linux::resolv_conf(
  Hash[String, Variant[String, Array[String]]] $base_settings,
  Hash[String, Variant[String, Array[String]]] $settings,
) {

  class { "resolv_conf":
    * => deep_merge($base_settings, $settings),
  }
}