class r_profile::ntp(
    $servers = hiera("r_profile::ntp::servers", undef),
) {
  if $virtual != "docker" {
    class { "ntp":
      disable_monitor => true,
      servers         => $servers,
    }
  }
}
