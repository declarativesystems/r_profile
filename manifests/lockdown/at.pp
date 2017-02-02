# R_profile::Lockdown::At
#
# Restrict access to the `at` daemon by managing the at.allow and at.deny files
#
# @param ensure true to enable lockdown of `at` otherwise false
class r_profile::lockdown::at(
  Boolean $ensure = hiera('r_profile::lockdown::at::ensure', false),
) {

  case $facts['os']['family'] {
    "RedHat": {
      $at_deny  = '/etc/at.deny'
      $at_allow = '/etc/at.allow'
    }
    "AIX": {
      $at_deny  = "/var/adm/cron/at.deny"
      $at_allow = "/var/adm/cron/at.allow"
    }
    "Solaris": {
      $at_deny  = "/etc/cron.d/at.deny"
      $at_allow = "/etc/cron.d/at.allow"
    }
    default:{
      fail("Class ${name} does not support ${facts['os']['family']} yet")
    }
  }

  if $ensure {
    file { $at_deny:
      ensure => absent,
    }

    # by creating this file, only users listed (and root!) will be able to
    # schedule at jobs
    file { $at_allow:
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
    }
  }
}
