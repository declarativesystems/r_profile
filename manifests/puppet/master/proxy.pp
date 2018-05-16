# R_profile::Puppet::Proxy
#
# Enable a Puppet Enterprise Master (not master's agent!) to work with a proxy server.
# To configure the master's agent for proxy support, include `r_profile::linux::puppet_agent`
#
# If using this class you must also declare r_profile::puppet::master in order
# to manage and notify Service['puppet']
#
# You must include the appropriate puppet agent class when using this one:
#   * include r_profile::linux::puppet_agent
#   * include r_profile::windows::puppet_agent
#
# @param proxy proxy server to use in the form http://user@pass:proxyhost:proxyport or false to not use a proxy server
class r_profile::puppet::master::proxy(
  $proxy                  = hiera("r_profile::puppet::master::proxy::proxy", false),
) inherits r_profile::puppet::params {

  $puppetconf             = "${::settings::confdir}/puppet.conf"
  $sysconf_puppetserver   = $r_profile::puppet::params::sysconf_puppetserver

  #
  # Proxy server in settings file
  #
  if $proxy {
    $proxy_ensure           = present
    $regexp                 = 'https?://(.*?@)?([^:]+):(\d+)'
    $proxy_host             = regsubst($proxy, $regexp, '\2')
    $proxy_port             = regsubst($proxy, $regexp, '\3')
    $http_proxy_var_gemrc   = "http_proxy: ${proxy}"
    $https_proxy_var_gemrc  = "https_proxy: ${proxy}"
    if $export_variable {
      # solaris needs a 2-step export
      $http_proxy_var   = "http_proxy=${proxy}; export http_proxy"
      $https_proxy_var  = "https_proxy=${proxy}; export https_proxy"
    } else {
      $http_proxy_var   = "http_proxy=${proxy}"
      $https_proxy_var  = "https_proxy=${proxy}"
    }
  } else {
    $proxy_ensure = absent
    $proxy_host = undef
    $proxy_port = undef
    # nasty hack - we MUST have two different space permuations here or
    # file_line will only remove a single entry as it has already matched
    $http_proxy_var  = " "
    $https_proxy_var = "  "
    $http_proxy_var_gemrc  = " "
    $https_proxy_var_gemrc = "  "
  }

  Ini_setting {
    ensure => $proxy_ensure,
  }

  File_line {
    ensure => $proxy_ensure,
  }

  # PMT (puppet.conf)
  ini_setting { "puppet.conf http_proxy_host":
    path    => $puppetconf,
    section => "user",
    setting => "http_proxy_host",
    value   => $proxy_host,
    notify  => Service['puppet'],
  }

  ini_setting { "puppet.conf http_proxy_port":
    path    => $puppetconf,
    section => "user",
    setting => "http_proxy_port",
    value   => $proxy_port,
    notify  => Service['puppet'],
  }

  # Enable pe-puppetserver to work with proxy
  file_line { "pe-puppetserver http_proxy":
    path   => $sysconf_puppetserver,
    line   => $http_proxy_var,
    match  => "http_proxy=",
    notify => Service['pe-puppetserver'],
  }

  file_line { "pe-puppetserver https_proxy":
    path   => $sysconf_puppetserver,
    line   => $https_proxy_var,
    match  => "https_proxy=",
    notify => Service['pe-puppetserver'],
  }

  # configure gem to work with system proxy - needed if using package{}
  # resources since they squash the environments
  $gemrc = "/root/.gemrc"

  file { $gemrc:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644"
  }

  file_line { "root gemrc http_proxy":
    path  => $gemrc,
    line  => $http_proxy_var_gemrc,
    match => "http_proxy:",
  }

  file_line { "root gemrc https_proxy":
    path  => $gemrc,
    line  => $https_proxy_var_gemrc,
    match => "https_proxy:",
  }
}
