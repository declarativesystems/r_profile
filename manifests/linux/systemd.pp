# R_profile::Linux::Systemd
#
# Provides:
#   * `Exec['systemctl_daemon_reload']` to scan for changed units when puppet changes them (invoke via notify)
#   * Enforcement of `sulogin` for rescue/emegency mode (this is the OS default)
#
# @see https://forge.puppet.com/puppetlabs/stdlib
#
# @param enforce_sulogin `true` to ensure `sulogin` used, false to leave files unaltered
class r_profile::linux::systemd(
    Boolean $enforce_sulogin = false,
) {

  # Provide a graph node that we can notify to get systemd to reload itself.
  # If this is not a systemd controlled system, we simply run the true command
  # instead so that we can exit with status 0
  if $facts['systemd_active'] {
    $command = "systemctl daemon-reload"
  } else {
    $command = "true"
  }

  if $enforce_sulogin {
    [
      "/usr/lib/systemd/system/rescue.service",
      "/usr/lib/systemd/system/emergency.service",
    ].each |$unit| {
      file_line { "${unit} single_user_use_sulogin":
        ensure => present,
        path   => $unit,
        match  => '^ExecStart=',
        line   => 'ExecStart=-/bin/sh -c "/sbin/sulogin; /usr/bin/systemctl --fail --no-block default'
      }
    }
  }

  exec { "systemctl_daemon_reload":
    command     => $command,
    refreshonly => true,
    path        => "/bin:/usr/bin:/usr/local/bin"
  }
}
