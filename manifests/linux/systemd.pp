# R_profile::Linux::Systemd
#
# Configure systemd on linux
class r_profile::linux::systemd {

  # Provide a graph node that we can notify to get systemd to reload itself.
  # If this is not a systemd controlled system, we simply run the true command
  # instead so that we can exit with status 0
  if $facts['systemd_active'] {
      $command = "systemctl daemon-reload"
  } else {
    $command = "true"
  }

  exec { "systemctl_daemon_reload":
    command     => $command,
    refreshonly => true,
    path        => "/bin:/usr/bin:/usr/local/bin"
  }
}
