# R_profile::Puppet::Master::Autosign
#
# Configure puppet for various autosigning techniques for client certificiates
#
# @param ensure Autosigning technique to use on this puppet master:
#   * `policy` Policy based autosigning @see http://www.geoffwilliams.me.uk/Puppet/policy_based_autosigning
#   * `accept_all` Automatically sign all certificate requests (not recommended for production use)
#   * `absent` Disable automatic certificate signing
# @param script_content If you would like to pass in your own script, pass a string of the content here or leave blank
#   to use the built-in shared secret comparison
# @param secret Shared secret to use when configuring policy based autosigning (only used with the built-in validation
#   script)
class r_profile::puppet::master::autosign(
    Enum['policy', 'absent', 'accept_all']  $ensure         = 'absent',
    String                                  $script_content = undef,
    String                                  $secret         = undef,
) {

  $autosign_script = "/usr/local/bin/puppet_enterprise_autosign.sh"

  case $ensure {
    "policy": {
      $autosign_setting = $autosign_script
    }
    "accept_all": {
      $autosign_setting = true
    }
    "absent": {
      $autosign_setting = false
    }
    default: {
      fail("Unsupported ensure autosign setting in ${name} (${ensure})")
    }
  }

  if $ensure == 'policy' and ! $secret {
    fail("Cannot enable policy based autosigning without a valid shared secret")
  }

  file { "autosign_conf":
    ensure => absent,
    path   => "${::settings::confdir}/autosign.conf",
    notify => Service["pe-puppetserver"]
  }

  # enable/disable autosign script in puppet.conf
  ini_setting { "puppet_conf_autosign_script":
    ensure  => present,
    path    => "${::settings::confdir}/puppet.conf",
    section => "master",
    setting => "autosign",
    value   => $autosign_setting,
    notify  => Service["pe-puppetserver"],
  }

  # the autosigning script
  if $script_content {
    $_script_content = $script_content
  } else {
    if $secret {
      $_script_content = epp("${module_name}/autosign.sh.epp", {secret=>$secret})
    } else {
      warning("no secret passed for autosigning - autosigning will not be not functional")
      $_script_content = ""
    }
  }

  file { $autosign_script:
    ensure  => present,
    owner   => "root",
    group   => "pe-puppet",
    mode    => "0770",
    content => $_script_content,
  }
}
