# R_profile::Linux::Base
#
# A basic Linux 'baseline' class
class r_profile::linux::base {
  include r_profile::linux::iptables
  include r_profile::linux::vim
  include r_profile::linux::sudo
  include r_profile::linux::systemd
  include r_profile::ntp
  include r_profile::linux::puppet_agent
  include r_profile::linux::package_manager
}
