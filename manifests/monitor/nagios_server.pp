# @summary Confifgure nagios server
#
# @param password Password to use for nagios
class r_profile::monitor::nagios_server(
    Optional[String] $password = undef,
) {
  include nagios
  class { "nagios::server":
    password => $password,
  }
}
