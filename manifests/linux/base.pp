class r_profile::linux::base {
  include r_profile::vim
  include r_profile::sudo
  include r_profile::systemd
  include r_profile::ntp
  include r_profile::linux::puppet_agent
}
