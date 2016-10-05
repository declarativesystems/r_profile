class r_profile::monitoring::nagios_server(
    $password = hiera("r_profile::monitoring::nagios_server::password", "nagios"),
) {
  include nagios
  class { "nagios::server":
    password => $password,
  }
}
