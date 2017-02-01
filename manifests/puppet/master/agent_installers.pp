# R_profile::Puppet::Master::Agent_installers
#
# Configure puppet to install the most common agent installers
class r_profile::puppet::master::agent_installers(
    $install = hiera('r_profile::puppet::master::agent_installers::install', true),
){

  class { 'psquared::agent_installers':
    install            => $install,
    install_osx_agents => false,
  }
}
