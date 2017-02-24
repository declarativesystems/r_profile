# R_profile::Puppet::Master::Agent_installers
#
# Configure puppet to install the most common agent installers
#
# @param install True to install all main Puppet agent installers
# @param install_osx True to also install the OSX Puppet agent installers
class r_profile::puppet::master::agent_installers(
    $install      = hiera('r_profile::puppet::master::agent_installers::install', true),
    $install_osx  = hiera('r_profile::puppet::master::agent_installers::install_osx', false),
){

  class { 'psquared::agent_installers':
    install            => $install,
    install_osx_agents => $install_osx,
  }
}
