# R_profile::Lockdown::At
#
# Restrict access to the `at` daemon by managing the at.allow and at.deny files
#
# @param ensure true to enable lockdown of `at` otherwise false
class r_profile::lockdown::at(
  Boolean $ensure = hiera('r_profile::lockdown::at::ensure', false),
) {

  if $ensure {
    file { '/etc/at.deny':
      ensure => absent,
    }

    # by creating this file, only users listed (and root!) will be able to
    # schedule at jobs
    file { '/etc/at.allow':
      ensure => present,
      owner  => 'root',
      group  => 'root',
      mode   => '0600',
    }
  }
}
