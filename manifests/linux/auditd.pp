# @summary Manage audit service and rules
#
# @see https://forge.puppet.com/geoffwilliams/auditd
#
# @example Puppet usage
#   include r_profile::linux::auditd
#
# @example Hiera data for general auditd settings
#   r_profile::linux::auditd::settings:
#     log_format: "ENHANCED"
#     max_log_file: 10
#     num_logs: 5
#     max_log_file_action: "rotate"
#
# @example Hiera data to manage rules
#
#
# @param rules Hash of rules to enforce (see examples)
# @param settings Hash or settings to apply to auditd (see examples)
# @param audispd_settings Hash of settings for the audispd.conf config file
class r_profile::linux::auditd(
    Hash[String, Hash[String,String]] $rules            = {},
    Hash[String, String]              $settings         = {},
    Hash[String, String]              $audispd_settings = {},
) {

  class { 'auditd':
    settings         => $settings,
    audispd_settings => $audispd_settings,
    rules            => $rules,
  }
}
