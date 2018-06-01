# R_profile::Linux::Puppet_agent
#
# Manage the Puppet Agent service and add support for proxy servers.
#
# The Puppet Agent is not managed by Puppet out-of-the box in current versions of Puppet Enterprise. In order to restart
# the service using Puppet, this class creates `Service['puppet']` so that restarts can be carried out as necessary.
#
# Proxy server support is managed by updating the systemd/init environment file to set the connection details.
#
# @see https://forge.puppet.com/puppetlabs/stdlib
#
# @param proxy `false` to skip configuration of a proxy server, otherwise the proxy server url, eg
#   `http://proxy.megacorp.com:8080`
# @param sysconf_puppet Path to sysconf file for puppet agent. Used to set proxy server environment variables
# @param puppet_agent_service Name of the Puppet Agent service to manage
# @param puppet_agent_enable `true` to start Puppet Agent on boot, otherwise `false`
# @param puppet_agent_ensure How to ensure the agent service
class r_profile::linux::puppet_agent(
    Variant[String, Boolean]    $proxy                = false,
    String                      $sysconf_puppet       = $r_profile::puppet::params::sysconf_puppet,
    Boolean                     $export_variable      = $r_profile::puppet::params::export_variable,
    String                      $puppet_agent_service = "puppet",
    Boolean                     $puppet_agent_enable  = true,
    Enum['running', 'stopped']  $puppet_agent_ensure  = 'running',
) inherits r_profile::puppet::params {

  # register the service so we can restart it if needed
  # PE-11353 means we may not need this forever
  service { $puppet_agent_service:
    ensure => $puppet_agent_ensure,
    enable => $puppet_agent_enable,
  }

  file { $sysconf_puppet:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  $puppet_agent_notifications = [
    Exec["systemctl_daemon_reload"],
    Service[$puppet_agent_service],
  ]

  File_line <| path == $sysconf_puppet |> ~> $puppet_agent_notifications

  #
  # Proxy server monkey patching
  #
  if $proxy {
    $proxy_ensure = present
    if $export_variable {
      # solaris needs a 2-step export
      $http_proxy_var   = "http_proxy=${proxy}; export http_proxy"
      $https_proxy_var  = "https_proxy=${proxy}; export https_proxy"
    } else {
      $http_proxy_var   = "http_proxy=${proxy}"
      $https_proxy_var  = "https_proxy=${proxy}"
    }
  } else {
    # remove any existing proxy info
    $proxy_ensure     = absent
    $http_proxy_var   = undef
    $https_proxy_var  = undef
  }

  file_line { "puppet agent http_proxy":
    ensure => $proxy_ensure,
    path   => $sysconf_puppet,
    line   => $http_proxy_var,
    match  => "http_proxy=",
  }

  file_line { "puppet agent https_proxy":
    ensure => $proxy_ensure,
    path   => $sysconf_puppet,
    line   => $https_proxy_var,
    match  => "https_proxy=",
  }
}

