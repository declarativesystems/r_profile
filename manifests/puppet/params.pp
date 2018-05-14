# R_profile::Puppet::Params
#
# Params pattern for puppet r_profile classes
#
# Settings class is a puppet built-in and is a ruby file found at:
# /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/settings.rb
class r_profile::puppet::params {

  # os-specific settings
  case $::osfamily {
    "Debian": {
      $sysconf_dir      = "/etc/default"
    }
    "RedHat": {
      $sysconf_dir      = "/etc/sysconfig"
    }
    "Solaris": {
      $sysconf_dir      = "/lib/svc/method"
    }
    "Suse": {
      $sysconf_dir      = "/etc/sysconfig"
    }
    "windows": {
      # no action needed
    }
    default: {
      fail("Unsupported osfamily ${facts['os']['family']} in profiles::puppet::params")
    }
  }


  # systemd detection
  if $::kernel == 'Linux' and dig($facts, 'systemd_active') == 'true' {
    # we are using systemd, we must NOT export a variable
    $export_variable = false
  } else {
    $export_variable = true
  }

  $sysconf_puppetserver   = "${sysconf_dir}/pe-puppetserver"
  $sysconf_puppet         = "${sysconf_dir}/puppet"


}
