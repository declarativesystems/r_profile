# R_profile::Linux::Auditd
#
# Ensure the auditd service is installed, running and has a fixed set of rules
# loaded.
#
# kemra102/auditd module from https://github.com/kemra102/puppet-auditd is used
# to provide auditd management. Pending a new forge release to address
# https://github.com/kemra102/puppet-auditd/issues/44 (merged) a hotfix module
# will be used instead
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
