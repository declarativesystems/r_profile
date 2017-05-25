# R_profile::Puppet::Master::Agent_installers
#
# Configure puppet to install the most common agent installers
#
# @param install True to install all main Puppet agent installers
class r_profile::puppet::master::agent_installers(
    $install      = hiera('r_profile::puppet::master::agent_installers::install', true),
){

  class { 'psquared::agent_installers':
    install            => $install,
  }
}
