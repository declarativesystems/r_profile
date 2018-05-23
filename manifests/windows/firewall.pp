# R_profile::Windows::Firewall
#
# Setup windows firewall and firewall rules. The idea is to enable the firewall
# and then allow specific exceptions (holes).
#
# @see https://forge.puppet.com/puppet/windows_firewall
#
# @example turning off firewall
#   r_profile::windows::firewall::ensure: stopped
#
# @example enabling firewall and setting exclusions
#   r_profile::windows::firewall::ensure: running
#   r_profile::windows::firewall::base_exception:
#     'WINRM':
#       direction: 'in'
#       action: 'allow'
#       enabled: 'yes'
#       protocol: 'TCP'
#       local_port: 5985
#       remote_port: 'any'
#       display_name: 'Windows Remote Management HTTP-In'
#       description: 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]'
#   r_profile::windows::firewall::exception:
#     'IIS':
#       direction: 'in'
#       action: 'allow'
#       enabled: 'yes'
#       protocol: 'TCP'
#       local_port: 80
#       remote_port: 'any'
#       display_name: 'IIS Web Server'
#       description: 'Inbound rule for IIS Web Server. [TCP 80]'
#
class r_profile::windows::firewall(
    Enum['stopped', 'running'] $ensure = 'running',
    Hash[String,Optional[Hash]] $base_exception = {},
    Hash[String,Optional[Hash]] $exception = {},
) {

  class { 'windows_firewall':
    ensure => $ensure,
  }

  merge($base_exception, $exception).each |$key, $opts| {
    windows_firewall::exception {
      default:
        ensure => present,
      ;

      $key:
        * => pick($opts, {}),
    }
  }
}