# Profile::Linux::Firewalld
#
# Manage firewalld using crayfishx-firewalld. Accepts base plus additional
# options for each set of rule resources being managed for easy managment
# using hiera. At runtime these will be run in order (base first).
#
# @example hiera data
#   firewalld
#
# @param enable True to manage firewalld rules, false to leave as-is
# @param base_firewalld_service base level `firewalld_service` rules
#   as a hash of options
# @param firewalld_service additional `firewalld_service` rules
#   as a hash of options
# @param base_firewalld_rich_rule base level `firewalld_rich_rule` rules
#   as a hash of options
# @param base_firewalld_rich_rule additional `firewalld_rich_rule` rules
#   as a hash of options
class profile::linux::firewalld(
  Boolean     $enable = true,
  Array[Hash] $base_firewalld_service = {},
  Array[Hash] $firewalld_service = {}
  Array[Hash] $base_firewalld_rich_rule = {},
  Array[Hash] $firewalld_rich_rule = {}
) {
  if $enable {
    class { "firewalld": }
    firewalld_zone { "public":
      ensure           => "present",
      target           => "default",
      masquerade       => false,
      purge_rich_rules => true,
      purge_services   => true,
      purge_ports      => true,
    }

    ($firewalld_service + $base_firewalld_service).each |$rule| {
      rule.each |$key, $opts| {
        firewalld_service { $key:
        * => $opts
      }
    }
  }

  ($firewalld_rich_rule + $base_firewalld_rich_rule).each |$rule| {
    $rule.each |$key, $opts| {
      firewalld_rich_rule { $key:
        * => $opts
      }
    }
  }

}
