# @summary Setup log rotation on Linux:
#
# Features:
#   * installation/configuration of logrotate
#   * rotation defaults
#   * individual rules
#
# @see https://forge.puppet.com/geoffwilliams/logrotate
#
# @example class usage
#   include r_profile::linux::logrotate
#
# @example Hiera data to set default rotation options:
#   r_profile::linux::logrotate::settings:
#     rotate: 10
#     weekly:
#     create:
#     dateext:
#
# @example Hiera data to set log rotation entries
#   r_profile::linux::logrotate::entries:
#     /var/log/httpd/*.log':
#       settings:
#         rotate: 5
#         mail: 'test@example.com'
#         size: '100k'
#         sharedscripts:
#         postrotate: '/etc/init.d/httpd restart'
#
# @param entries Hash of logrotate entries to create (see examples)
# @param settings Hash of default settings for `logrotate.conf` (see examples)
class r_profile::linux::logrotate(
    Hash[String, Optional[Hash]]  $entries  = {},
    Hash[String, Any]             $settings = {}
) {

  class { 'logrotate':
    settings => $settings,
    entries  => $entries,
  }

}