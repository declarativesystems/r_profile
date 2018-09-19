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
#   r_profile::linux::auditd::rules:
#     10_date_and_time:
#       content: |
#         # data and time
#         -a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
#         -a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change
#         -a always,exit -F arch=b64 -S clock_settime -k time-change
#         -a always,exit -F arch=b32 -S clock_settime -k time-change
#         -w /etc/localtime -p wa -k time-change
#     20_user_and_groups:
#       content: |
#         # users and groups
#         -w /etc/group -p wa -k identity
#         -w /etc/passwd -p wa -k identity
#         -w /etc/gshadow -p wa -k identity
#         -w /etc/shadow -p wa -k identity
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
