# R_profile::Puppet::Master::License
#
# Install a puppet license key onto the puppet Master.  This works by symlinking
# the license.key file from your control repository to the correct location on
# the puppet master.  To upgrade or alter your license information, just update
# the file in the control repository (production branch) and then deploy to the
# master as usual.
#
# @example
#   include r_pofile::puppet::master::license
#
class r_profile::puppet::master::license {
  file { "/etc/puppetlabs/license.key":
    ensure => link,
    owner  => "root",
    group  => "root",
    mode   => "0755",
    target => "/etc/puppetlabs/code/environments/production/license.key",
  }
}
