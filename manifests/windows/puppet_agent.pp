# R_profile::Window::Puppet_agent
#
# Setup a puppet agent on Windows
class r_profile::windows::puppet_agent(
    $puppet_path          = hiera("r_profile::windows::puppet_agent::puppet_path", 'c:/Program Files/PuppetLabs/puppet/bin'),
    $proxy                = hiera("r_profile::puppet::proxy", false),
    $puppet_agent_service = $r_profile::puppet::params::puppet_agent_service,
) inherits r_profile::puppet::params {
  #package { "ConEmu":
  #  ensure => present,
  #}

  if $proxy {
    $proxy_ensure = present
  } else {
    $proxy_ensure = absent
  }

  if $puppet_path {
    $puppet_path_ensure = present
  } else {
    $puppet_path_ensure = absent
  }

  service { $puppet_agent_service:
    ensure => running,
    enable => true,
  }

  # puppet binaries in path
  windows_env { 'puppet_path':
    ensure    => $puppet_path_ensure,
    value     => $puppet_path,
    mergemode => insert,
    variable  => "Path",
    notify    => Reboot["puppet_reboot"],
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
