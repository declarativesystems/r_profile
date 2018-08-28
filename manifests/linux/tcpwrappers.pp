# @summary Setup tcpwrappers
#
# Setup tcpwrappers using geoffwilliams/tcpwrappers. We will merge
# together a set of base level (SOE) rules and addtional/more
# specific rules. This allows hiera to be kept simple without having
# to worry about its merge capabilities.
#
# @param base_rules_allow Basic set of rules for hosts.allow
# @param base_rules_deny Basic set of rules for hosts.deny
# @param rules_allow Additional rules for hosts.allow
# @param rules_deny Additional rules for hosts.deny
# @param hosts_allow_content Full content for hosts.allow
# @param hosts_deny_content Full content for hosts.deny
class r_profile::linux::tcpwrappers(
  Array[Hash[String, String]] $base_rules_allow = [],
  Array[Hash[String, String]] $base_rules_deny  = [],
  Array[Hash[String, String]] $rules_allow = [],
  Array[Hash[String, String]] $rules_deny  = [],
  Variant[String, Boolean] $hosts_allow_content = false,
  Variant[String, Boolean] $hosts_deny_content = false,
) {
  class { 'tcpwrappers':
    rules_allow         => $base_rules_allow + $rules_allow,
    rules_deny          => $base_rules_deny + $rules_deny,
    hosts_allow_content => $hosts_allow_content,
    hosts_deny_content  => $hosts_deny_content,
  }
}
