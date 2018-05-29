# R_profile::Windows::Registry
#
# Manage Windows registry entries with Puppet using puppetlabs-registry
# @see https://forge.puppet.com/puppetlabs/registry
#
# @example hiera data
#   r_profile::windows::registry::base_registry_key:
#     'HKLM\System\CurrentControlSet\Services\Puppet':
#   r_profile::windows::registry::base_registry_value:
#     'HKLM\System\CurrentControlSet\Services\Puppet\Description':
#       type: string
#       data: "The Puppet Agent service periodically manages your configuration"
#   r_profile::windows::registry::registry_key:
#     'HKLM\System\CurrentControlSet\Services\Nagios':
#   r_profile::windows::registry::registry_value:
#     'HKLM\System\CurrentControlSet\Services\Nagios\Description':
#       type: string
#       data: "Nagios service periodically monitors your computer"
#
# @param base_registry_key Hash of registry keys to create (see example)
# @param base_registry_value Hash of registry values to create (see example)
# @param registry_key Hash of registry keys to create (see example)
# @param registry_value Hash of registry values to create (see example)
class r_profile::windows::registry(
    Hash[String, Optional[Hash]] $base_registry_key   = {},
    Hash[String, Optional[Hash]] $base_registry_value = {},
    Hash[String, Optional[Hash]] $registry_key        = {},
    Hash[String, Optional[Hash]] $registry_value      = {},
) {

  merge($base_registry_key, $registry_key).each |$key, $opts| {
    registry_key {
      default:
        ensure => present,
      ;
      $key:
        * => pick($opts, {})
    }
  }

  merge($base_registry_value, $base_registry_value).each |$key, $opts| {
    registry_value {
      default:
        ensure => present,
      ;
      $key:
        * => pick($opts, {})
    }
  }

}