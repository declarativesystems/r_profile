# R_profile::Linux::Puppet_agent
#
# Manages:
#   * Puppet Agent service
#   * Proxy server environment variable support
#
# The Puppet Agent is not managed by Puppet Enterprise out of the box (but PXP Agent is...). To restart them using
# Puppet we create service resources for them here so that restarts can be carried out as necessary.
#
# To support proxy servers, we set the `http_proxy` and `https_proxy` environment variables for both agents. Scheduled
# Puppet agent runs will use the defaults from `sysconf_puppet`, Puppet agent initiated by PXP (run puppet button) uses
# `sysconf_pxp_agent`. By setting the environment in both files, consistency can be reached, apart from when running
# directly on the command line with `puppet agent -t`. In this case, the operator is resposonsible for its own
# environment
#
# @see https://forge.puppet.com/puppetlabs/stdlib
#
# @param proxy `false` to skip configuration of a proxy server, otherwise the proxy server url, eg
#   `http://proxy.megacorp.com:8080`
# @param sysconf_puppet Path to sysconf file for puppet agent. Used to set proxy server environment variables
# @param sysconf_pxp_agent Path to sysconf file for pxp agent. Used to set proxy server environment variables
# @param puppet_agent_service Name of the Puppet Agent service to manage
# @param puppet_agent_enable `true` to start Puppet Agent on boot, otherwise `false`
# @param puppet_agent_ensure How to ensure the Puppet Agent service
# @param pxp_agent_service Name of the PXP Agent service to manage
class r_profile::linux::puppet_agent(
    Variant[String, Boolean]    $proxy                = false,
    String                      $sysconf_puppet       = "${facts['sysconf_dir']}/puppet",
    String                      $sysconf_pxp_agent    = "${facts['sysconf_dir']}/pxp-agent",
    String                      $puppet_agent_service = "puppet",
    Boolean                     $puppet_agent_enable  = true,
    Enum['running', 'stopped']  $puppet_agent_ensure  = 'running',
    String                      $pxp_agent_service    = "pxp-agent",
) {

  # register the service so we can restart it if needed
  # PE-11353 means we may not need this forever
  service { $puppet_agent_service:
    ensure => $puppet_agent_ensure,
    enable => $puppet_agent_enable,
  }


  file { [$sysconf_puppet, $sysconf_pxp_agent]:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  $puppet_agent_notifications = [
    Exec["systemctl_daemon_reload"],
    Service[$puppet_agent_service],
  ]

  $pxp_agent_notifications = [
    Exec["systemctl_daemon_reload"],
    Service[$pxp_agent_service],
  ]


  File_line <| path == $sysconf_puppet |> ~> $puppet_agent_notifications
  File_line <| path == $sysconf_pxp_agent |> ~> $pxp_agent_notifications

  #
  # Proxy server monkey patching
  #
  if $proxy {
    $proxy_ensure = present
    if $facts['systemd_active'] {
      $http_proxy_var   = "http_proxy=${proxy}"
      $https_proxy_var  = "https_proxy=${proxy}"
    } else {
      # solaris needs a 2-step export
      $http_proxy_var   = "http_proxy=${proxy}; export http_proxy"
      $https_proxy_var  = "https_proxy=${proxy}; export https_proxy"
    }
  } else {
    # remove any existing proxy info
    $proxy_ensure     = absent
    $http_proxy_var   = "http_proxy="
    $https_proxy_var  = "https_proxy="
  }

  file_line { "puppet agent http_proxy":
    ensure => $proxy_ensure,
    path   => $sysconf_puppet,
    line   => $http_proxy_var,
    match  => "http_proxy=",
  }

  file_line { "pxp agent http_proxy":
    ensure => $proxy_ensure,
    path   => $sysconf_pxp_agent,
    line   => $http_proxy_var,
    match  => "http_proxy=",
  }

  file_line { "puppet agent https_proxy":
    ensure => $proxy_ensure,
    path   => $sysconf_puppet,
    line   => $https_proxy_var,
    match  => "https_proxy=",
  }

  file_line { "pxp agent https_proxy":
    ensure => $proxy_ensure,
    path   => $sysconf_pxp_agent,
    line   => $https_proxy_var,
    match  => "https_proxy=",
  }

}

