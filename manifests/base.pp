class r_profile::base {
  include r_profile::puppet::agent
  include r_profile::systemd
  include r_profile::motd 
  include r_profile::software
  include r_profile::vim
  include r_profile::ntp
}
