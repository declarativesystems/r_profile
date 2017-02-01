# R_profile::Fw::Post
#
# 'post' rules for iptables
class r_profile::fw::post {
  Firewall {
    before => undef,
  }

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

}
