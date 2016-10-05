class r_profile::monitor::nagios_server(
    $password = hiera("r_profile::monitor::nagios_server::password", "nagios"),
) {
  include nagios
  class { "nagios::server":
    password => $password,
  }
}
