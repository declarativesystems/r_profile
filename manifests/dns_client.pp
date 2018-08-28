# @summary Support for configuring the DNS client
#
# Manges (/etc/resolve.conf) and the Name
# Service Switch (/etc/nsswitch.conf and friends)
# @see https://forge.puppet.com/geoffwilliams/resolv_conf/readme
# @see https://forge.puppet.com/geoffwilliams/name_service_switch/readme
#
# @param search Domain to attempt resolution of short hostsnames in first
# @param nameservers Array of nameservers to use
# @param options Options Array of options to use
# @param nss_entries Hash of settings to add to the nsswitch.conf file
# @param install_defaults True to install module default DNS/NSS settings if
#   nothing found in hiera, otherwise dont' reconfigure dns
class r_profile::dns_client(
    $search           = hiera("r_profile::dns_client::search", undef),
    $nameservers      = hiera("r_profile::dns_client::nameservers", undef),
    $options          = hiera("r_profile::dns_client::options", undef),
    $nss_entries      = hiera("r_profile::dns_client::nss_entries", undef),
    $install_defaults = hiera("r_profile::dns_client::install_defaults", false),
) {

  # setup /etc/resolve.conf
  if $nameservers or $install_defaults {
    class { "resolv_conf":
      search      => $search,
      nameservers => any2array($nameservers),
      options     => $options,
    }
  }

  if $nss_entries or $install_defaults {
    class { "name_service_switch":
      entries => $nss_entries,
    }
  }
}
