# @summary Enable a Puppet Enterprise Master to work with a proxy server
#
# @note This does not configure the master's agent. Use `r_profile::linux::puppet_agent`
# for this
#
# If using this class you must also declare `r_profile::puppet::master` in order
# to manage and notify `Service['pe-puppetserver']`
#
# @see https://forge.puppet.com/puppetlabs/inifile
# @see https://forge.puppet.com/puppetlabs/stdlib
#
# @example setting the proxy server
#   r_profile::puppet::master::proxy::proxy: http://proxy.megacorp.com:3128
#
# @example disable proxy server (the default)
#   r_profile::puppet::master::proxy::proxy: false
#
# @param proxy proxy server to use in the form http://user@pass:proxyhost:proxyport or `false` to not use a proxy server
# @param sysconf_puppetserver Path to systemd/init environment file for PuppetServer
# @param puppetconf_proxy `true` to also add proxy information to `puppet.conf`. If set, all operations on Puppet will
#   use the proxy server and there is no ability to bypass, so this will break commands such as `puppet node`. If we
#   are deconfigiuring a proxy server, then always remove proxy server info from `puppet.conf`.
#   @see ENTERPRISE-1175
class r_profile::puppet::master::proxy(
  Variant[String, Boolean] $proxy                   = false,
  String                   $sysconf_puppetserver    = "${facts['sysconf_dir']}/pe-puppetserver",
  Boolean                  $puppetconf_proxy        = false,
) {

  $puppetconf             = "${::settings::confdir}/puppet.conf"

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
    if $facts['systemd_active'] {
      $http_proxy_var = "http_proxy=${proxy}"
      $https_proxy_var = "https_proxy=${proxy}"
    } else {
      # solaris needs a 2-step export
      $http_proxy_var   = "http_proxy=${proxy}; export http_proxy"
      $https_proxy_var  = "https_proxy=${proxy}; export https_proxy"
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
  if $puppetconf_proxy or ! $proxy {
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
