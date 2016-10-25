$configs = {
  '/tmp/config.php' => {
    'vars' => {
      'db_user' => 'quote',
      'db_password' => 'quote',
      'db_host' => 'localhost',
      'db_name' => 'quote',
    }
  }
}
class { 'r_profile::webapp::php_config':
  configs => $configs,
}
