# @summary Enable a simple built-in Git Server for puppet
#
# Works by creating a bare git grepository accessed via SSH and configuring Code Manager to use it
#
# @param enable true to enable the git server, otherwise do nothing
class r_profile::puppet::master::git_server(
  Boolean $enable = hiera('r_profile::puppet::master::git_server::enable', true),
) {
  if $enable {
    include psquared::git
  }
}
