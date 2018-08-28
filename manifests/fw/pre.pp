# @summary 'pre' rules for iptables
class r_profile::fw::pre {
#  package { 'iptables':
#    ensure => present,
#  }

  # make sure iptables installed before trying to do any firewall
  # stuff
#  Package['iptables'] -> Firewall<| |>

  Firewall {
    require => undef,
  }

  # Default firewall rules
  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  }
  -> firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }
  -> firewall { '002 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }
  -> firewall { '003 allow SSH':
    proto  => 'tcp',
    dport  => 22,
    action => 'accept',
  }

}
