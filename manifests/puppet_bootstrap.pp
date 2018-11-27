# @summary Cleanup any initial bootstrap configuration
#
# `puppet_bootstrap` can be used to join new nodes to Puppet but it requires
# plaintext credentials be stored on the system until the new node is joined to
# puppet. This class ensures that all stray credentials are removed and also
# ensures a consistent bootstrap menu is in-place, should a node require a new
# certificate be generated.
#
# @see https://forge.puppet.com/puppetlabs/inifile
# @see https://github.com/GeoffWilliams/puppet_bootstrap
#
# @example Configuring a standard menu
#   profile::puppet_bootstrap::menu:
#     "pp_environment": "dev,test,prod"
#     "pp_zone": "nothing,dmz"
#     "pp_role": "role::base,role::webserver,role::appserver"
#
# @example Don't manage the `puppet_bootstrap.cfg` file
#   profile::puppet_bootstrap::manage: false
#
# @param manage `true` to remove credentials and manage menu items, otherwise
#   `false`
# @param menu Hash of menu items to manage. By managing all allowed fields a
#   fleet-wide consistent menu can be built (see example)
class profile::puppet_bootstrap(
  Boolean             $manage = true,
  Hash[String,String] $menu   = {},
) {

  $puppet_bootstrap_cfg = $facts['kernel'] ? {
    "windows" => "c:/ProgramData/puppet_bootstrap/puppet_bootstrap.cfg",
    "Linux"   => "/etc/puppet_bootstrap/puppet_bootstrap.cfg",
  }

  if $manage {
    # make sure no-one deleted our CFG file by accident..
    file { dirname($puppet_bootstrap_cfg):
      ensure => directory,
    }

    file { $puppet_bootstrap_cfg:
      ensure => file,
    }

    # remove all credentials
    ["username", "password", "server", "shared_secret"].each |$setting| {
      ini_setting { "${puppet_bootstrap_cfg}/main/${setting}":
        ensure  => absent,
        section => "main",
        setting => $setting,
        path    => $puppet_bootstrap_cfg,
      }
    }

    $menu.each |$setting, $value| {
      ini_setting { "${puppet_bootstrap_cfg}/menu/${setting}":
        ensure  => present,
        section => "key",
        setting => $setting,
        value   => $value,
        path    => $puppet_bootstrap_cfg,
      }
    }
  }
}