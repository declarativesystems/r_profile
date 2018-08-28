# @summary Management of the IPtables Linux firewall
#
# @param ensure `managed` take control of the IPtables firewall, `disabled` turn
#   IPtables off, `unmanaged` do not change firewall settings
class r_profile::linux::iptables(
    Enum['managed', 'disabled', 'unmanaged'] $ensure = 'unmanaged',
) {
  # Suggested global firewall defaults declared in r10k-control/manifests/site.pp
  #Firewall {
  #  before  => Class['profile::fw::post'],
  #  require => Class['profile::fw::pre'],
  #}

  if $ensure == 'managed' {
    include firewall
    include r_profile::fw::pre
    include r_profile::fw::post
  } elsif $ensure == 'disabled' {
    class { 'firewall':
      ensure => stopped,
    }
  } # else unmanaged, so do nothing
}
