# R_profile::Linux::At
#
# Setup the `at` scheduler:
# * Remove `at.deny` so that only allowed users can run `at`
# * Strict permissions on `at.allow`
# * Allow `root` to use `at`
#
# @see https://forge.puppet.com/puppetlabs/stdlib
class r_profile::linux::at {
  file { "/etc/at.deny":
    ensure => absent,
  }

  file { "/etc/at.allow":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0400",
  }

  file_line { "/etc/at.allow root":
    ensure => present,
    line   => "root",
    path   => "/etc/at.allow"
  }
}