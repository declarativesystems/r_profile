# @summary SSH support on linux using Augeas.
#
# @see https://forge.puppet.com/geoffwilliams/ssh
# @see https://forge.puppet.com/herculesteam/augeasproviders_ssh
# @see https://forge.puppet.com/herculesteam/augeasproviders_core
#
# @example Usage
#   include r_profile::linux::ssh
#
# @example Hiera data
#   r_profile::linux::ssh::settings:
#     permit_root_login: no
#     banner: /etc/banner
#
# @param settings Hash of all settings to pass through to the SSH module. See above link for details
class r_profile::linux::ssh(
  Hash[String, Variant[String,Array[String]]] $settings = {},
) {
  class { "ssh":
    settings => $settings,
  }
}