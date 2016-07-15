class r_profile::windows::puppet_agent(
    $puppet_path          = hiera("r_profile::windows::puppet_agent::puppet_path", 'c:/Program Files/PuppetLabs/puppet/bin'),
    $proxy                = hiera("r_profile::puppet::proxy", false),
    $puppet_agent_service = $::r_profile::puppet::params::puppet_agent_service,
) inherits $::r_profile::puppet::params {
  #package { "ConEmu":
  #  ensure => present,
  #}
    
  service { $puppet_agent_service:
    ensure => running,
    enable => true,
  }

  # puppet binaries in path
  windows_env { 'puppet_path':
    ensure    => $puppet_path,
    value     => $puppet_path,
    mergemode => insert,
    variable  => "Path",
  }


  #
  # proxy support
  # 
  windows_env { [ 'http_proxy', 'https_proxy' ]:
    ensure    => $proxy,
    value     => $proxy,
    mergemode => clobber,
  }

  # reboot instance for all code to use
  reboot { "puppet_reboot":
    subscribe => [
      Windows_env["http_proxy"],
      Windows_env["https_proxy"],
      Windows_env["puppet_path"],
    ],
  }
}
