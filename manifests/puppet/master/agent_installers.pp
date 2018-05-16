# R_profile::Puppet::Master::Agent_installers
#
# Configure puppet to install the most common agent installers
#
# @param install True to install all main Puppet agent installers
class r_profile::puppet::master::agent_installers(
    $install      = hiera('r_profile::puppet::master::agent_installers::install', true),
){


  # prevent timeout errors
  Pe_staging::File {
    timeout => 1800, # 30 mins
  }

  if $install {
    $platform_classes = r_profile::list_agent_platforms()
    $platform_classes.each |$platform_class| {
      include $platform_class
    }
  }
}
