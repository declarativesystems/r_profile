# R_profile::Dns_client
#
# Support for configuring the DNS client (/etc/resolve.conf)
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
