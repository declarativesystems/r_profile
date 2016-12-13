# Lockdown::Service
#
# Stop and disable the passed in service list
# @param $services List of services to stop and disable
class r_profile::lockdown::service($services = []) {
  service { $services:
    ensure => stopped,
    enable => false,
  }
}
