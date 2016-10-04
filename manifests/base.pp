class r_profile::base {
  Firewall {
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  if $enable_firewall {
    class { 'firewall':}
    class {'r_profile::fw::pre','profile::fw::post':}
  } else {
    class { 'firewall':
      ensure => stopped,
    }
  }

  include r_profile::motd
  include r_profile::software
  include r_profile::users
  include "r_profile::${downcase($kernel)}::base"
  include r_profile::nagios_monitored
}
