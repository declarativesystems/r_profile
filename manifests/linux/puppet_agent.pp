# setup a puppet agent (currently just fixes proxy settings...)
class r_profile::linux::puppet_agent(
    $proxy                        = hiera("r_profile::puppet::proxy", false),
    $sysconf_puppet               = $::r_profile::puppet::params::sysconf_puppet,
    $export_variable              = $::r_profile::puppet::params::export_variable,
    $puppet_agent_service         = $::r_profile::puppet::params::puppet_agent_service,
) inherits r_profile::puppet::params {

  # Docker containers should not ordinarily run puppet
  if $virtual != "docker" {
    if $proxy {
      $proxy_ensure = present
    } else {
      $proxy_ensure = absent
    }

    # register the service so we can restart it if needed
    # PE-11353 means we may not need this forever
    service { $puppet_agent_service:
      ensure => running,
      enable => true,
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
      $regexp = 'https?://(.*?@)?([^:]+):(\d+)'
      $proxy_host = regsubst($proxy, $regexp, '\2')
      $proxy_port = regsubst($proxy, $regexp, '\3')
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
      $http_proxy_var   = "http_proxy="
      $https_proxy_var  = "https_proxy="
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
}
