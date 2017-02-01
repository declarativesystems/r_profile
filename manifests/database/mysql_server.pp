# R_profile::Database::Mysql_server
#
# Install the MySQL database server
class r_profile::database::mysql_server(
    $root_password    = hiera("r_profile::database::mysql_server::root_password", 'changeme'),
    $override_options = hiera("r_profile::database::mysql_server::override_options", undef),
    $db               = hiera("r_profile::database::mysql_server::db", {}),
    $db_default       = hiera("r_profile::database::mysql_server::db_default", {}),
    $nagios_monitored = hiera("r_profile::database::mysql_server::nagios_monitored", true),
    $open_firewall    = hiera("r_profile::database::mysql_server::open_firewall", false),
) {

  # always 3306
  $port = 3306

  class { '::mysql::server':
    root_password           => $root_password,
    remove_default_accounts => true,
    override_options        => $override_options
  }

  create_resources("mysql::db", $db, $db_default)

  if $nagios_monitored {
    nagios::nagios_service_tcp { 'MySQL':
      port => $port,
    }
  }

  if $open_firewall and !defined(Firewall["100 ${::fqdn} TCP ${port}"]) {
    firewall { "100 ${::fqdn} TCP ${port}":
      dport  => $port,
      proto  => 'tcp',
      action => 'accept',
    }
  }

}
