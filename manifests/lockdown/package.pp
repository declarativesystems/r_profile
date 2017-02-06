# R_profile::Lockdown::Package
#
# Purge the passed-in packages from the system
#
# @param $delete List of packages to purge
class r_profile::lockdown::package(
    Array[String] $delete = hiera("r_profile::lockdown::package::delete", [])
) {
  package { $delete:
    ensure => purged,
  }
}
