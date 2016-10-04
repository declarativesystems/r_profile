class r_profile::linux::firewall($enable=true) {
  # Suggested global firewall defaults declared in r10k-control/manifests/site.pp
  #Firewall {
  #  before  => Class['profile::fw::post'],
  #  require => Class['profile::fw::pre'],
  #}

  if $enable {
    include firewall
    include r_profile::fw::pre
    include r_profile::fw::post
  } else {
    class { 'firewall':
      ensure => stopped,
    }
  }
}
