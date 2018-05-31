# R_profile::Puppet::Master::Autosign
#
# Configure Puppet Enterprise to autosign client certificates:
#   * Policy based autosigning @https://puppet.com/docs/puppet/5.5/ssl_autosign.html#policy-based-autosigning
#   * Naive autosigning @see https://puppet.com/docs/puppet/5.5/ssl_autosign.html#nave-autosigning
#   * No autosigning @see https://puppet.com/docs/puppet/5.5/ssl_autosign.html#disabling-autosigning
#
# If Policy based autosigning is enabled, then a script to check for the presence of the shared secret passed in
# `secret` will be created for you. If you would rather install your own script then you may pass the body of the script
# file in `script_content` and this profile will write it out for you.
#
# In all cases `autosign.conf` is removed. This file offers pattern-based autosigning which does not fit the above
# patterns yet may still be present on the system.
#
# @example Hiera to enable signing all certificates
#   r_profile::puppet::master::autosign::ensure: accept_all
#
# @example Hiera to enable policy based autosigning with a shared secret (encrypted with eyaml)
#   r_profile::puppet::master::autosign::ensure: policy
#   r_profile::puppet::master::autosign::secret: >
#     ENC[PKCS7,Y22exl+OvjDe+drmik2XEeD3VQtl1uZJXFFF2NnrMXDWx0csyqLB/2NOWefv
#     NBTZfOlPvMlAesyr4bUY4I5XeVbVk38XKxeriH69EFAD4CahIZlC8lkE/uDh
#     jJGQfh052eonkungHIcuGKY/5sEbbZl/qufjAtp/ufor15VBJtsXt17tXP4y
#     l5ZP119Fwq8xiREGOL0lVvFYJz2hZc1ppPCNG5lwuLnTekXN/OazNYpf4CMd
#     /HjZFXwcXRtTlzewJLc+/gox2IfByQRhsI/AgogRfYQKocZgFb/DOZoXR7wm
#     IZGeunzwhqfmEtGiqpvJJQ5wVRdzJVpTnANBA5qxeA==]
#
# @example Hiera to enable policy based autosigning with your own custom script
#   r_profile::puppet::master::autosign::ensure: policy
#   r_profile::puppet::master::autosign::script_content: |-
#     #!/bin/bash
#     echo "Hello, World!"
#
# @param ensure Autosigning technique to use on this puppet master (see above)
# @param script_content If you would like to pass in your own script, pass a string of the content here or leave blank
#   to use the built-in shared secret check
# @param secret Shared secret to use when configuring policy based autosigning (only for built-in shared-secret script)
# @param autosign_script Path to save the autosigning script
class r_profile::puppet::master::autosign(
    Enum['policy', 'absent', 'accept_all']  $ensure           = 'absent',
    Optional[String]                        $script_content   = undef,
    Optional[String]                        $secret           = undef,
    String                                  $autosign_script  = "/usr/local/bin/puppet_enterprise_autosign.sh",
) {

  case $ensure {
    "policy": {
      $autosign_setting = $autosign_script
      $script_ensure    = present

      # the autosigning script
      if $script_content {
        $_script_content = $script_content
      } else {
        if $secret {
          $_script_content = epp("${module_name}/autosign.sh.epp", {secret=>$secret})
        } else {
          fail("r_profile::puppet::master::autosign - no secret passed for autosigning - autosigning will not be not functional")
          $_script_content = ""
        }
      }
    }
    "accept_all": {
      $autosign_setting = true
      $script_ensure    = absent
      $_script_content  = undef
    }
    "absent": {
      $autosign_setting = false
      $script_ensure    = absent
      $_script_content  = undef
    }
    default: {
      fail("Unsupported ensure autosign setting in ${name} (${ensure})")
    }
  }

  # always remove `autosign.conf` which enables somewhat more finegrained auto-acceptance - its easily spoofable
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


  file { $autosign_script:
    ensure  => $script_ensure,
    owner   => "root",
    group   => "pe-puppet",
    mode    => "0770",
    content => $_script_content,
  }
}
