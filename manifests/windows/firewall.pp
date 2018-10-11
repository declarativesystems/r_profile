# @summary Manage the windows advanced firewall.
#
# Features:
#   * Global settings
#   * Per-profile settings
#   * Enable/disable rulegroups by name
#   * Mange firewall rules
#
# Items to create are grouped into base and non-base to allow easy management in
# Hiera. Items in non-base can override those in base.
#
# @see https://forge.puppet.com/geoffwilliams/windows_firewall
#
# @example turning off all firewalls
#   # you must quote values to avoid type coercion
#   # https://github.com/GeoffWilliams/puppet-windows_firewall/issues/1
#   r_profile::windows::firewall::profiles:
#     private:
#       state: 'off'
#     public:
#       state: 'off'
#     domain:
#       state: 'off'
#
# @example Ensuring firewall rules
#   r_profile::windows::firewall::rules:
#     'Windows Remote Management HTTP-In':
#       direction: 'in'
#       action: 'allow'
#       enable: 'yes'
#       protocol: 'TCP'
#       localport: 5985
#       remoteport: 'any'
#       description: 'Inbound rule for Windows Remote Management via WS-Management. [TCP 5985]'
#     'IIS Web Server':
#       direction: 'in'
#       action: 'allow'
#       enable: 'yes'
#       protocol: 'TCP'
#       localport: 80
#       remoteport: 'any'
#       description: 'Inbound rule for IIS Web Server. [TCP 80]'
#
# @example Configuring per-profile settings
#   r_profile::windows::firewall::profiles:
#     private:
#       filename: '%systemroot%\system32\logfiles\firewall\pfirewall.log'
#       firewallpolicy: 'blockinbound,allowoutbound'
#       inboundusernotification: 'disable'
#       logallowedconnections: 'disable'
#       logdroppedconnections: 'disable'
#       maxfilesize: '4096'
#       remotemanagement: 'disable'
#       state: 'on'
#       unicastresponsetomulticast: 'enable'
#
# @example Configuring global firewall settings
#   r_profile::windows::firewall::global:
#     authzcomputergrp: 'none'
#     authzusergrp: 'none'
#     defaultexemptions:
#       - 'neighbordiscovery'
#       - 'dhcp'
#     forcedh: 'yes'
#     ipsecthroughnat: 'serverbehindnat'
#     keylifetime: '485min,0sess'
#     saidletimemin: '6'
#     secmethods: 'dhgroup2:aes128-sha1,dhgroup2:3des-sha1'
#     statefulftp: 'disable'
#     statefulpptp: 'disable'
#     strongcrlcheck: '1'
#
# @example Enabling a group of rules
#   r_profile::windows::firewall::group:
#     "file and printer sharing":
#       enabled: "yes"
#
# @example Purging unmanaged rules (use with caution!)
#   r_profile::windows::firewall::purge_rules: true
#
# @param base_profiles Base profile settings (see examples)
# @param profiles Override profile settings (see examples)
# @param base_rules Base rules (see examples)
# @param rules Override rules (see examples)
# @param base_global Base global settings (see examples)
# @param global Override global settings (see examples)
# @param base_groups Base group settings (see examples)
# @param groups Override group settings (see examples)
# @param purge_rules `true` to purge all unmanaged firewall rules, otherwise
#   leave existing rules in place
class r_profile::windows::firewall(
    Hash[String, Hash]  $base_profiles  = {},
    Hash[String, Hash]  $profiles       = {},
    Hash[String, Hash]  $base_rules     = {},
    Hash[String, Hash]  $rules          = {},
    Hash[String, Hash]  $base_global    = {},
    Hash[String, Hash]  $global         = {},
    Hash[String, Hash]  $base_groups    = {},
    Hash[String, Hash]  $groups         = {},
    Boolean             $purge_rules    = false,
) {

  resources { "windows_firewall_rule":
    purge => $purge_rules,
  }

  deep_merge($base_profiles, $profiles).each |$key, $opts| {
    windows_firewall_profile { $key:
      * => $opts,
    }
  }

  deep_merge($base_rules, $rules).each |$key, $opts| {
    windows_firewall_rule {
      default:
        ensure => present,
      ;

      $key:
        * => $opts,
    }
  }

  deep_merge($base_groups, $groups).each |$key, $opts| {
    windows_firewall_group { $key:
      * => $opts,
    }
  }

  # only need shallow merge for global hash since its only one level deep
  windows_firewall_global { "global":
    * => merge($base_global, $global),
  }

}