# R_profile::Linux::Sysctl
#
# Control sysctl values (kernel tuning) on Linux.  Not to be confused with
# systemctl (services).
#
# Settings will take place immediately when puppet is run and will also be
# persisted /etc/sysctl.d to survive across reboots.  There is no support in
# this class for removing entries that have previously been set since the
# previous setting is unknowable.  If restoring a previously tuned parameter to
# its default is required, the manual restoration steps on each agent are:
# 1.  Remove the setting from the passed in $settings list (hiera data)
# 2.  Remove the corresponding file under /etc/sysctl.d on the agent node
# 3.  Reboot...
#
# Alternatively, set the $purge option to true and now puppet will remove
# unmanaged files under /etc/sysctl.d for us.  The process now looks like this:
# 1.  Remove the setting from the passed in $settings list (hiera data)
# 2.  Reboot...
#
# Settings to enforce should be passed as a hash via the settings parameter, eg
#
# Hiera:
#   r_profile::linux::sysctl::settings:
#     net.ipv4.conf.all.accept_redirects: 0
#     net.ipv4.tcp_syncookies: 1
#
# Puppet code:
#   {
#     'net.ipv4.conf.all.accept_redirects' => 0,
#     'net.ipv4.tcp_syncookies'            => 1
#   }
#
# Requires: thias/puppet-sysctl
#
# @param purge Purge unmanaged files from /etc/sysctl.d
# @param settings Hash of settings as key=>value pairs
class r_profile::linux::sysctl(
    Boolean $purge              = hiera('r_profile::linux::sysctl::purge', false),
    Hash[String, Any] $settings = hiera('r_profile::linux::sysctl::settings', {})
){

  # enable purging to work, if selected
  class { "sysctl::base":
    purge => $purge,
  }

  $settings.each |$key, $value| {
    sysctl { $key:
      value  => $value,
      notify => Exec["flush_routing_tables"],
    }
  }

  exec { "flush_routing_tables":
    command     => "/sbin/sysctl -w net.ipv4.route.flush=1",
    refreshonly => true,
  }
}
