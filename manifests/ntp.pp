# R_profile::Ntp
#
# A more general-purpose NTP
#
# Supports:
# * AIX (in this class)
# * Solaris (puppetlabs-ntp)
# * Linux (puppetlabs-ntp)
#
# @param servers Array of servers to ask for the time
# @param package_manage True if we should install ntp otherwise false
# @param service_manage True if we should control the ntpd service otherwise false
# @param service_name Name of the service to manage if we are instructed to do so
class r_profile::ntp(
    $servers                = hiera("r_profile::ntp::servers", undef),
    Boolean $package_manage = hiera("r_profile::ntp::package_manage", true),
    Boolean $service_manage = hiera("r_profile::ntp::service_manage", true),
    $service_name           = hiera("r_profile::ntp::service_name", undef),
) {
  if $facts['virtual'] != "docker" {
    class { "ntp":
      servers        => $servers,
      package_manage => $package_manage,
      service_manage => $service_manage,
      service_name   => $service_name,
    }
  }
}
