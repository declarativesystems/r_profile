# R_profile::Lockdown::Package
#
# Purge the passed-in packages from the system
#
# @param $packages List of packages to purge
class r_profile::lockdown::package(
    Array[String] $packages = []
) {
  package { $packages:
    ensure => purged,
  }
}
