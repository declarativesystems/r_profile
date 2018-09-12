# @summary Management of the IPtables Linux firewall
#
# @see https://forge.puppet.com/puppetlabs/firewall
#
# @example Disable the firewall
#   r_profile::linux::iptables::ensure: disabled
#
# @example Don't purge unmanaged rules
#   r_profile::linux::iptables::purge: false
#
# @example Enable Management of IPTables
#   r_profile::linux::iptables::ensure: running
#
# @example Set some rules
#   # rules are grouped into `pre`, `main` and `post - suggest `pre` and `post
#   # rules are used to ensure access at all times and correct default rules
#   # then use the `base_main` and `main` rules to setup the rules you want for
#   # your site
#   r_profile::linux::iptables::pre_rules:
#     '000 accept all icmp':
#       proto: 'icmp'
#       action: 'accept'
#     '001 accept all to lo interface':
#       proto: 'all'
#       iniface: 'lo'
#       action: 'accept'
#     '002 reject local traffic not on loopback interface':
#       iniface: '! lo'
#       proto: 'all'
#       destination: '127.0.0.1/8'
#       action: 'reject'
#     '003 accept related established rules':
#       proto: 'all'
#       state:
#         - 'RELATED'
#         - 'ESTABLISHED'
#       action: 'accept'
#     '004 Allow SSH':
#       chain: 'INPUT'
#       state: 'NEW'
#       action: 'accept'
#       proto: 'tcp'
#       dport: 22
#
#   r_profile::linux::iptables::main_rules:
#     '200 Allow oracle':
#       chain: 'INPUT'
#       state: 'NEW'
#       action: 'accept'
#       proto: 'tcp'
#       dport: 1521-1524
#
#   r_profile::linux::iptables::post_rules:
#     '999 drop all':
#       proto: 'all'
#       action: 'drop'
#
# @param ensure `running` start the the IPtables firewall, `stopped` turn
#   IPtables off, `unmanaged` do not change firewall settings
# @param pre_rules Set of _system_ rules to setup _first_ (see example)
# @param base_main_rules Base set of _user_ rules (see example)
# @param main_rules Override set of _user_ rules (see example)
# @param post_rules Set of _system_ rules to apply _last_ (see example)
# @param purge `true` to purge existing rules from system, otherwise `false`
class r_profile::linux::iptables(
    Enum['stopped', 'running', 'unmanaged']   $ensure          = 'unmanaged',
    Hash[String, Hash]                        $pre_rules       = {},
    Hash[String, Hash]                        $base_main_rules = {},
    Hash[String, Hash]                        $main_rules      = {},
    Hash[String, Hash]                        $post_rules      = {},
    Boolean                                   $purge           = true,
) {


  if $ensure == 'unmanaged' {
    # do nothing
  } else {

    class { "firewall":
      ensure => $ensure,
    }

    # Insist on `pre` rules to prevent lockout
    if $pre_rules.size == 0 {
      warn("${name}::pre_rules not found - skip firewall rules to prevent lockout")
    } elsif $ensure == "running" {
      resources { 'firewall':
        purge => $purge,
      }

      (
        $pre_rules + deep_merge($pre_rules, $base_main_rules) + $post_rules
      ).each |$title, $opts| {
        firewall {
          default:
            ensure  => present,
            require => Class["firewall"],
          ;
          $title:
            * => $opts,
        }
      }
    }
  }
}
