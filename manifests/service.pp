# R_profile::Service
#
# Ensure the listed services are `running` and enabled on boot
#
# @param enable List of services to start and enable
class r_profile::service(
    Array[String] $enable = [],
) {


  $enable.each |$service| {
    service { $service:
      ensure => running,
      enable => true,
    }
  }
}