class r_profile::linux::ntp(
    $servers = hiera("r_profile::ntp::servers", undef),
) {
  if $virtual != "docker" {
    class { "ntp":
      servers         => $servers,
    }
  }
}
