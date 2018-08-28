# @summary Manage the Puppet agent on Windows
#
# Manages:
#   * Puppet Agent service
#   * Puppet binaries in `$PATH`
#   * Proxy server environment variables (ruby uses these instead of the windows proxy information in registry)
#   * Reboot after making any of the above changes in order to activate them
#
# @param puppet_path Ensure this directory is in `$PATH` or pass `false` to do nothing
# @param proxy `false` Proxy server url to use with Puppet, eg `http://proxy.megacorp.com:8080`. Pass `false` to
#   deconfigure proxy support
# @param puppet_agent_service Name of the Puppet Agent service to manage
# @param puppet_agent_enable `true` to start Puppet Agent on boot, otherwise `false`
# @param puppet_agent_ensure How to ensure the Puppet Agent service
# @param pxp_agent_service Name of the PXP Agent service to manage
class r_profile::windows::puppet_agent(
    Variant[Boolean, String]    $puppet_path          = 'c:/Program Files/PuppetLabs/puppet/bin',
    Variant[Boolean, String]    $proxy                = false,
    String                      $puppet_agent_service = "puppet",
    Enum['running', 'stopped']  $puppet_agent_ensure  = 'running',
    Boolean                     $puppet_agent_enable  = true,
    String                      $pxp_agent_service    = "pxp-agent",
) {

  if $proxy {
    $proxy_ensure = present
  } else {
    $proxy_ensure = absent
  }

  if $puppet_path {
    # puppet binaries in path
    windows_env { 'puppet_path':
      ensure    => present,
      value     => $puppet_path,
      mergemode => insert,
      variable  => "Path",
      notify    => Reboot["puppet_reboot"],
    }
  }

  service { $puppet_agent_service:
    ensure => $puppet_agent_ensure,
    enable => $puppet_agent_enable,
  }

  #
  # proxy support
  #
  windows_env { [ 'http_proxy', 'https_proxy' ]:
    ensure    => $proxy_ensure,
    value     => $proxy,
    mergemode => clobber,
    notify    => Reboot["puppet_reboot"],
  }

  # reboot instance for all code to use
  reboot { "puppet_reboot": }
}
