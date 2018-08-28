# @summary Install Puppet Enterprise agents for all supported platforms
#
# Puppet Enterprise doesn't ship with the installers needed for every platform included in the installation media.'Users
# must instead follow the steps at https://puppet.com/docs/pe/2018.1/installing/installing_agents.html#ariaid-title2
# which involves createating classifier groups and manually classifying each installer you wish to provide.
#
# This class automates the process by:
#   1. A custom function that inspects the puppet master for the avaiable installer classes
#   2. Include each class so that the agent installer will be downloaded (requires internet access/proxy be setup)
#
# There are 1GB+ of installers to download so this can take a long time
#
# @example Download all agent installers
#   include r_profile::puppet::master::agent_installers
#
# @example Hiera data to prevent agent installer download
#   r_profile::puppet::master::agent_installers::install: false
#
# @param install `true` to install all main Puppet agent installers, `false` to skip downloading
class r_profile::puppet::master::agent_installers(
    Boolean $install = true,
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
