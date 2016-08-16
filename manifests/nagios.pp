class r_profile::nagios(
    $password = hiera("r_profile::nagios::password", "nagios"),
) {
  class nagios {
    password => $password,
  }
}
