# R_profile::Puppet::Params
#
# Settings class is a puppet built-in and is a ruby file found at:
# /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/settings.rb
class r_profile::puppet::params {

  # PE 2015/AIO agent
  $puppet_agent_service = "puppet"
  $_codedir             = $::settings::codedir
  $mco_service          = "mcollective"

  # os-specific settings
  case $::osfamily {
    "debian": {
      # fixme - check this!
      warning("debian is untested with profiles::puppet::params!")
      $sysconf_dir      = "/etc/default"
      $export_variable  = true
    }
    "redhat": {
      $sysconf_dir = "/etc/sysconfig"
    }
    "solaris": {
      $sysconf_dir      = "/lib/svc/method"
      $export_variable  = true
    }
    "windows": {
      # no action needed
    }
    default: {
      notify { "Unsupported osfamily ${::osfamily} in profiles::puppet::params": }
    }
  }


  # systemd detection
  if $::osfamily == 'RedHat' {
    if $::operatingsystemrelease =~ /^7/ or $::operatingsystem == 'Fedora' {
      # we are using systemd, we must NOT export a variable
      $export_variable = false
    } else {
      $export_variable = true
    }
  } else {
    warning ("systemd detection in profiles::puppet::params doesn't support non-redhat os")
  }

  $sysconf_puppetserver   = "${sysconf_dir}/pe-puppetserver"
  $sysconf_puppet         = "${sysconf_dir}/${puppet_agent_service}"
  $hieradir               = "${_codedir}/environments/%{environment}/hieradata"
  $basemodulepath         = "${::settings::confdir}/modules:/opt/puppetlabs/puppet/modules"
  $environmentpath        = "${_codedir}/environments"
  $git_config_file        = "/root/.gitconfig"
  $puppetconf             = "${::settings::confdir}/puppet.conf"
  $generate_r10k_mco_cert = true
  $autosign_script        = "/usr/local/bin/autosign.sh"
  $data_binding_terminus  = "hiera"

  $db_backup_dir          = "/tmp"
  $db_backup_hour         = 5
  $db_backup_minute       = 0
  $db_backup_month        = "*"
  $db_backup_monthday     = "*"
  $db_backup_weekday      = "*"

  $hierarchy_base      = [
    "nodes/%{clientcert}",
    "roles/%{role}",
    "app_tier/%{app_tier}",
    "datacenter/%{datacenter}",
    "env/%{environment}",
    "common",
  ]

  if $virtual == "docker" {
    # if running under docker or in dockerbuild, enable an additional level of
    # hierarchy to disable code manager and optionally tune memory usage down.
    # This technique allows us to control these settings independently of the
    # r10k control repo, which is needed so that the docker image building
    # system has a hiera data file that it owns to avoid checking out a control
    # repo that will inadvertantly change or remove settings we need to exist
    #
    # final file location: /etc/puppetlabs/code/system.yaml
    $hierarchy_default = concat($hierarchy_base, "../../../system")

  } else {
    $hierarchy_default = $hierarchy_base
  }

}
