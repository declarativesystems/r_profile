# R_profile::Lockdown::Service
#
# Stop and disable the passed in service list
# @param $disable List of services to stop and disable
class r_profile::lockdown::service(
    Array[String]  $disable = hiera("r_profile::lockdown::service::disable", []),
) {
  service { $disable:
    ensure => stopped,
    enable => false,
  }
}
