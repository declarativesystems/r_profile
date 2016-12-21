# r_profile::puppet::proxy
#
# Enable a Puppet Enterprise Master to work with a proxy server
#
# @param proxy proxy server to use in the form http://user@pass:proxyhost:proxyport or false to not use a proxy server
class r_profile::puppet::master::proxy(
  $proxy                  = hiera("r_profile::puppet::master::proxy::proxy", false),
) inherits r_profile::puppet::params {

  $puppetconf             = $r_profile::puppet::params::puppetconf
  $sysconf_puppetserver   = $r_profile::puppet::params::sysconf_puppetserver

  #
  # Proxy server in settings file
  #
  if $proxy {
    $proxy_ensure = present
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
    $proxy_ensure = absent
    $proxy_host = undef
    $proxy_port = undef
    # nasty hack - we MUST have two different space permuations here or
    # file_line will only remove a single entry as it has already matched
    $http_proxy_var  = " "
    $https_proxy_var = "  "
  }

  Ini_setting {
    ensure => $proxy_ensure,
  }

  # PMT (puppet.conf)
  ini_setting { "puppet.conf http_proxy_host":
    path     => $puppetconf,
    section  => "user",
    setting  => "http_proxy_host",
    value    => $proxy_host,
  }

  ini_setting { "puppet.conf http_proxy_port":
    path    => $puppetconf,
    section => "user",
    setting => "http_proxy_port",
    value   => $proxy_port,
  }

  # Enable pe-puppetserver to work with proxy
  file_line { "pe-puppetserver http_proxy":
    ensure => present,
    path   => $sysconf_puppetserver,
    line   => $http_proxy_var,
    match  => "http_proxy=",
  }

  file_line { "pe-puppetserver https_proxy":
    ensure => present,
    path   => $sysconf_puppetserver,
    line   => $https_proxy_var,
    match  => "https_proxy=",
  }


}
