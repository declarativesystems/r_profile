class r_profile::nagios_server(
    $password = hiera("r_profile::nagios_server::password", "nagios"),
) {
  include nagios
  class { "nagios::server":
    password => $password,
  }

}
