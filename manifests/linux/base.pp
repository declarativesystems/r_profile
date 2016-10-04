class r_profile::linux::base {
  include r_profile::linux::firewall
  include r_profile::linux::vim
  include r_profile::linux::sudo
  include r_profile::linux::systemd
  include r_profile::linux::ntp
  include r_profile::linux::puppet_agent
  include r_profile::linux::package_manager
}
