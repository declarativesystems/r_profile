# R_profile::Dns_client
#
# Support for configuring the DNS client (/etc/resolve.conf) and the Name
# Service Switch (/etc/nsswitch.conf and friends)
# @see https://forge.puppet.com/geoffwilliams/resolv_conf/readme
# @see https://forge.puppet.com/geoffwilliams/name_service_switch/readme
#
# @param search Domain to attempt resolution of short hostsnames in first
# @param nameservers Array of nameservers to use
# @param options Options Array of options to use
# @param nss_entries Hash of settings to add to the nsswitch.conf file
class r_profile::dns_client(
    $search       = hiera("r_profile::dns_client::search", undef),
    $nameservers  = hiera("r_profile::dns_client::nameservers", undef),
    $options      = hiera("r_profile::dns_client::options", undef),
    $nss_entries  = hiera("r_profile::dns_client::nss_entries", undef),
) {

  # setup /etc/resolve.conf
  class { "resolv_conf":
    search      => $search,
    nameservers => $nameservers,
    options     => $options,
  }

  class { "name_service_switch":
    entries => $nss_entries,
  }

}
