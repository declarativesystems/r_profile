# Setup NTPd on linux using the puppetlabs-ntp module.
#
# Requires:  puppetlabs-ntp
#
# @param servers Array of servers to ask for the time
# @param package_manage True if we should install ntp otherwise false
# @param service_manage True if we should control the ntpd service otherwise false
class r_profile::linux::ntp(
    $servers                = hiera("r_profile::ntp::servers", undef),
    Boolean $package_manage = hiera("r_profile::ntp::package_manage", true),
    Boolean $service_manage = hiera("r_profile::ntp::service_manage", true),
) {
  if $virtual != "docker" {
    class { "ntp":
      servers        => $servers,
      package_manage => $package_manage,
      service_manage => $service_manage,
    }
  }
}
