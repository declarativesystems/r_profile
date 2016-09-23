class r_profile::puppet::master (
    $hiera_eyaml                  = true,
    $git_server                   = true,
    $autosign_ensure              = absent,
    $db_backup_ensure             = hiera("r_profile::puppet::master::db_backup_ensure", absent),
    $db_backup_dir                = hiera("r_profile::puppet::master::db_backup_dir",
      $r_profile::puppet::params::db_backup_dir),
    $db_backup_hour               = hiera("r_profile::puppet::master::db_backup_hour",
      $r_profile::puppet::params::db_backup_hour),
    $db_backup_minute             = hiera("r_profile::puppet::master::db_backup_minute",
      $r_profile::puppet::params::db_backup_minute),
    $db_backup_month              = hiera("r_profile::puppet::master::db_backup_month",
      $r_profile::puppet::params::db_backup_month),
    $db_backup_monthday           = hiera("r_profile::puppet::master::db_backup_monthday",
      $r_profile::puppet::params::db_backup_monthday),
    $db_backup_weekday            = hiera("r_profile::puppet::master::db_backup_weekday",
      $r_profile::puppet::params::db_backup_weekday),
    $policy_based_autosign_ensure = hiera("r_profile::puppet::master::policy_based_autosign_ensure", absent),
    $autosign_script              = $r_profile::puppet::params::autosign_script,
    $autosign_secret              = hiera("r_profile::puppet::master::autosign_secret", false),
    $proxy                        = hiera("r_profile::puppet::proxy", false),
    $sysconf_puppetserver         = $r_profile::puppet::params::sysconf_puppetserver,
    $data_binding_terminus        = hiera("r_profile::puppet::master::data_binding_terminus", 
      $r_profile::puppet::params::data_binding_terminus),
#    $deploy_pub_key      = "",
#    $deploy_private_key  = "",
    $environmentpath              = $r_profile::puppet::params::environmentpath,
    $puppetconf                   = $r_profile::puppet::params::puppetconf,
    $export_variable              = $r_profile::puppet::params::export_variable,
    $hierarchy                    = $r_profile::puppet::params::hierarchy_default,
    $hieradir                     = $r_profile::puppet::params::hieradir,
) inherits r_profile::puppet::params {

  validate_bool($hiera_eyaml)
  if ($autosign_script) {
    validate_absolute_path($autosign_script)
  }
  if $autosign_ensure == present and $policy_based_autosign_ensure == present {
    fail("Only one of autosign_ensure or policy_based_autosign_ensure can be set in r_profile::puppet::master")
  }

  File {
    owner => "root",
    group => "root",
  }

  if $hiera_eyaml {
    $backends = [ "eyaml" ]
  } else {
    $backends = [ "hiera" ]
  }

  class { "hiera":
    hierarchy       => $hierarchy,
    hiera_yaml      => "/etc/puppetlabs/puppet/hiera.yaml",
    datadir         => $hieradir,
    backends        => $backends,
    eyaml           => $hiera_eyaml,
    owner           => "pe-puppet",
    group           => "pe-puppet",
    provider        => "puppetserver_gem",
    eyaml_extension => "yaml",
    notify          => Service["pe-puppetserver"],
  }

  include r_profile::puppet::policy_based_autosign
  include r_profile::puppet::db_backup
  if $git_server {
    include psquared::git
  }


  file { "autosign":
    ensure  => $autosign_ensure,
    content => "*",
    path    => "${::settings::confdir}/autosign.conf",
    notify  => Service["pe-puppetserver"]
  }

  file { $sysconf_puppetserver:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  # restart master service if any file_lines change its config file
  File_line <| path == $sysconf_puppetserver |> ~>  [ 
    Exec["systemctl_daemon_reload"],
    Service["pe-puppetserver"],
  ]

  # data binding terminus explicit
  ini_setting { "puppet.conf data_binding_terminus":
    ensure  => present,
    setting => "data_binding_terminus",
    value   => $data_binding_terminus,
    section => "master", 
    path    => $puppetconf,
    notify  => Service["pe-puppetserver"],
  }

  #
  # Proxy server monkey patching
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
    # nasty hack - we MUST have two different space permuations here or 
    # file_line will only remove a single entry as it has already matched 
    $http_proxy_var  = " "
    $https_proxy_var = "  "
  }

  Ini_setting {
    ensure => $proxy_ensure,
  }

  # PMT (puppet.conf)
  ini_setting { "pmt proxy host":
    path     => $puppetconf,
    section  => "user",
    setting  => "http_proxy_host",
    value    => $proxy_host,
  }

  ini_setting { "pmt proxy port":
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

  # patch the puppetserver gem command for SERVER-377
  if $pe_server_version =~ /2015/ or $pe_server_version =~ /2016.[0124]/ {
    $file_to_patch = "/opt/puppetlabs/server/apps/puppetserver/cli/apps/gem"
    $patch_pe_gem = true
  } elsif $puppetversion =~ /3.8.* \(Puppet Enterprise/ {
    $file_to_patch = "/opt/puppet/share/puppetserver/cli/apps/gem"
    $patch_pe_gem = true
  } else {
    notify { "this version of Puppet Enterprise might not need puppetserver gem to be patched, please check for a newer version of this module at https://github.com/GeoffWilliams/r_profile/ and raise an issue if there isn't one": }
    $patch_pe_gem = false
  }
  $line = "-Dhttps.proxyHost=${proxy_host} -Dhttp.proxyHost=${proxy_host} -Dhttp.proxyPort=${proxy_port} -Dhttps.proxyPort=${proxy_port} \\"

  if $patch_pe_gem {
    file_line { "gem http_proxy":
      ensure => $proxy_ensure,
      path   => $file_to_patch,
      match  => "^-Dhttps.proxyHost=",
      after  => "puppet-server-release.jar",
      line   => $line,
    }
  }

  include r_profile::puppet::agent_installers 
}
