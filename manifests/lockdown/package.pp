# Purge the passed-in packages from the system
#
# @param $packages List of packages to purge
class r_profile::lockdown::package($packages = []) {
  package { $packages:
    ensure => purged,
  }
}
