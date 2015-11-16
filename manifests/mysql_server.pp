class r_profile::mysql_server(
    $root_password,
    $override_options = undef,
    $db               = hiera("r_profile::mysql_server::db", {}),
    $db_default       = hiera("r_profile::mysql_server::db_default", {}),
) {
  class { '::mysql::server':
    root_password           => $root_password,
    remove_default_accounts => true,
    override_options        => $override_options
  }

  create_resources("mysql::db", $db, $db_default)
}
