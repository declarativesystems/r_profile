# R_profile::Lockdown::Group
#
# Lockdown groups by removing them.
#
# @param delete Array of groups to delete from the system
class r_profile::lockdown::group(
    Array[String] $delete = hiera("r_profile::lockdown::group::delete", []),
) {

  group { $delete:
    ensure => absent,
  }
}
