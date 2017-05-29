# R_profile::Puppet::Nr_agent
#
# Install non-root puppet agent(s).  Typically useful if you want to manage
# cloud resources with puppet and reqiure multiple puppet agents to do so.
#
# Rquires that your puppet master hostname is resolvable already, either via DNS
# or `/etc/hosts`
#
# Since puppet must already be installed on a node (as root) to be able to run
# this class, we do not attempt to (re)install puppet.  This means we cannot use
# the puppet curl|bash installer and must instead create the appropriate settings
# files and services
#
# @example Installing non-root agents
#   class { "r_profile::puppet::nr_agent":
#     puppet_master_fqdn => "puppet.megacorp.com",
#     agents             => {
#       "azureprovisioner.megacorp.com" => {
#         "user"    => "puppet_azure",
#         "secret"  => "shared_secret_for_autosigning",
#       }
#     },
#   }
#
# @param puppet_master_fqdn The FQDN of the puppet master
# @param agents Hash of agents to install, where each hash member's key is the
#   certname of the agent to install and the value is a hash of options for this
#   agent
class r_profile::puppet::nr_agent(
    String          $puppet_master_fqdn = hiera("r_profile::puppet::nr_agent::puppet_master_fqdn", undef),
    Optional[Hash]  $agents             = hiera("r_profile::puppet::nr_agent::agents"),
) {

  $agents.each |$certname, $opts| {
    puppet_nonroot { $certname:
      *                  => $opts,
      puppet_master_fqdn => $puppet_master_fqdn,
    }
  }
}
