# r_profile::linux::logrotate
#
# Setup log rotation on Linux:
#   * installation/configuration of logrotate
#   * rotation defaults
#   * individual rules
#
# @see https://forge.puppet.com/puppet/logrotate
#
# @example class usage
#   include r_profile::linux::logrotate
#
# @example Hiera data to set default rotation options:
#   r_profile::linux::logrotate::default_settings:
#     rotate: 10
#     rotate_every: 'week'
#     ifempty: true
#     dateext: true
#
# @example Hiera data to set rules
#   r_profile::linux::logrotate::rules:
#     'apache':
#       path: '/var/log/httpd/*.log'
#       rotate: 5
#       mail: 'test@example.com'
#       size: '100k'
#       sharedscripts: true
#       postrotate: '/etc/init.d/httpd restart'
#
# @param rules Hash of rules to configure logrotate with (see examples. Complete list of allowable keys at
#   https://github.com/voxpupuli/puppet-logrotate/blob/master/manifests/rule.pp)
# @param default_settings hash of default log rotation settings (see examples. Complete list of allowable keys at
#   https://github.com/voxpupuli/puppet-logrotate/blob/master/manifests/conf.pp)
class r_profile::linux::logrotate(
    Hash[String, Optional[Hash]]  $rules            = {},
    Hash[String, Any]             $default_settings = {
      "rotate"        => 5,
      "rotate_every"  => "day",
      "ifempty"      => true,
    },
) {

  class { '::logrotate':
    config => $default_settings,
  }


  $rules.each |$key, $opts| {
    logrotate::rule { $key:
      * => pick($opts, {}),
    }
  }
}