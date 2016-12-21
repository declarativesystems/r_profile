class r_profile::puppet::master::git_server(
  Boolean $install = hiera('r_profile::puppet::master::install', true),
) {
  if $install {
    include psquared::git
  }
}
