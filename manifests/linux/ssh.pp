# R_profile::Linux::Ssh
#
# SSH support on linux
# @see https://forge.puppet.com/geoffwilliams/ssh
#
# @example hiera data
#   r_profile::linux::ssh::settings:
#     permit_root_login: no
#     banner: /etc/banner
#
# @param settings Hash of all settings to pass through to the SSH module. See above link for details
class r_profile::linux::ssh(
  Hash[String, Optional[Variant[String, Hash]]] $settings = {},
) {
  class { "ssh":
    * => $settings,
  }
}