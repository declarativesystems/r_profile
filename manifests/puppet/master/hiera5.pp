# @summary Hiera v5 support
#
# Enable support for Hiera v5 system-wide by copying-in a golden `hiera.yaml`
# file and restarting puppet.  Individual environments can then specify the
# hiera hierarchy they want to use as required.
#
# The inserted file defines a global hierarchy file for use by puppet at
# `/etc/puppetlabs/puppet_enterprise.yaml`. This is a file NOT managed by git
# and is for putting settings to re-configure puppet enterprise without using
# git, as directed by support/documentation. The main use of this _trick_ is
# to enable the initial `puppet code deploy` to succeed when using a private
# forge
class r_profile::puppet::master::hiera5 {
  file { "/etc/puppetlabs/puppet/hiera.yaml":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
    source => "puppet:///modules/${module_name}/hiera.yaml",
    notify => Service["pe-puppetserver"],
  }

  file { "/etc/puppetlabs/puppet_enterprise.yaml":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }
}
