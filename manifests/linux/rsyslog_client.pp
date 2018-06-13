# R_profile::Linux::Rsyslog
#
# Setup `rsyslog` client.
#
# After settings are present in the `/etc/rsyslog.conf` we also ensure any logfiles mentioned have the correct
# permissions
#
# @see https://forge.puppet.com/puppet/rsyslog
#
# @example Setup syslog client with settings from hiera
#   include r_profile::linux::rsyslog
#
# @example specifying log files to manage in Hiera (we will manage permissons where `value` is a filename)
#   r_profile::linux::rsyslog_client::logs:
#     'cron_log':
#       'key': 'cron.*'
#       'value': '/var/log/cron'
#     'emerg_log':
#       'key': '*.emerg',
#       'value': ':omusrmsg:*'
#     'news_log':
#       'key': 'uucp,news.crit'
#       'value': '/var/log/spooler'
#
# @param settings Hash of settings to use. These will be passed directly to the `rsyslog::client` class so the supported
#   settings are whatever this class supports @see https://github.com/voxpupuli/puppet-rsyslog/issues/64 for current
#   example of how to setup a client. The exception to this is that the content of class parameter `logs` will be used
#   to populate the `legacy_config` section. This allows the log files to be specified separately.
# @param logs Hash of logs to manage. This maps to the `legacy_config` parameter on the `rsyslog::client` class. Where a
#   `value` looks like a filename (see example) we will manage permissions on the file too.
# @param log_group Group to grant ownership of log files to
# @param log_mode File mode to give to log files
# @param manage_permissions `true` to manage permissions as described above otherwise `false` to leave alone
class r_profile::linux::rsyslog_client(
  Hash    $settings           = {},
  Hash    $logs               = {},
  String  $log_group          = "root",
  String  $log_mode           = "0600",
  Boolean $manage_permissions = false,
) {

  if $manage_permissions {
    $logs.each |$key, $opts| {
      if $opts["value"] =~ /^\// {
        file { $opts["value"]:
          ensure => file,
          owner  => "root",
          group  => $log_group,
          mode   => $log_mode,
        }
      }
    }
  }

  class { 'rsyslog::client':
    *             => $settings,
    legacy_config => $logs,
  }

}