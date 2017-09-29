# R_profile::Puppet::Master::Hiera5
#
#
# Enable support for Hiera v5 system-wide by copying-in a golden `hiera.yaml`
# file and restarting puppet.  Individual environments can then specify the
# hiera hierarchy they want to use as required
class r_profile::puppet::master::hiera5 {
  file { "/etc/puppetlabs/puppet/hiera.yaml":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
    source => "puppet:///modules/${module_name}/hiera.yaml",
    notify => Service["pe-puppetserver"],
  }
}
