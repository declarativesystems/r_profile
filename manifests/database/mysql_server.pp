# R_profile::Database::Mysql_server
#
# Install the MySQL database server
#
# @see https://forge.puppet.com/puppetlabs/mysql
#
# @example Basic usage
#   include r_profile::database::mysql_server
#
# @example Server settings
#   r_profile::database::mysql_server::settings:
#     root_password: "TopSecr3t"
#     remove_default_accounts: true
#
# @example Database creation
#   r_profile::database::mysql_server::dbs:
#     'mydb':
#       user: 'myuser'
#       password: 'mypass'
#       host: 'localhost'
#       grant:
#         - 'SELECT'
#         - 'UPDATE'
#
# @param settings Hash of server settings to enforce (see examples)
# @param dbs Hash of databases to create (see examples)
class r_profile::database::mysql_server(
    Hash[String, Any]               $settings = {},
    Hash[String, Hash[String, Any]] $dbs      = {},
) {

  class { 'mysql::server':
    * => $settings,
  }

  $dbs.each |$key, $opts| {
    mysql::db { $key:
      * => $opts,
    }
  }

}
