# R_profile::Puppet::Master::Git_server
#
# Enable a simple built-in Git Server for puppet by creating a bare git
# repository accessed via SSH and configuring Code Manager to use it
#
# @param enable true to enable the git server, otherwise do nothing
class r_profile::puppet::master::git_server(
  Boolean $enable = hiera('r_profile::puppet::master::git_server::enable', true),
) {
  if $enable {
    include psquared::git
  }
}
