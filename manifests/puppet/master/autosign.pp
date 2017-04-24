# R_profile::Puppet::Master::Autosign
#
# Configure puppet for various autosigning techniques for client certificiates
#
# @param ensure Autosigning technique to use on this puppet master:
#   * `policy` Policy based autosigning @see http://www.geoffwilliams.me.uk/Puppet/policy_based_autosigning
#   * `accept_all` Automatically sign all certificate requests (not recommended for production use)
#   * `absent` Disable all varieties of automatic certificate signing
# @param template Template to use as a script to validate certificate requests
#   when using policy based autosigning.  The default script allows new CSRs to
#   be compared against a shared secret, set in the seperate `secret` parameter.
#   In many cases, this is all thats required, however by supplying your own
#   script, your able to do exotic checks such as validation against the AWS API
# @param secret Shared secret to use when configuring policy based autosigning
#   and using the built-in template as the validation script
class r_profile::puppet::master::autosign(
    Enum['policy', 'absent', 'accept_all'] $ensure =
      hiera('r_profile::puppet::master::autosign::ensure', 'absent'),
    $template = hiera('r_profile::puppet::master::autosign::template', "${module_name}/autosign.sh.erb"),
    $secret   = hiera('r_profile::puppet::master::autosign::secret',undef),
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
  file { $autosign_script:
    ensure  => present,
    owner   => "root",
    group   => "pe-puppet",
    mode    => "0770",
    content => template($template),
  }
}
