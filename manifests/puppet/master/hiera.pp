# R_profile::Puppet::Master::Hiera
#
# Configure hiera based on passed-in hierachy
class r_profile::puppet::master::hiera(
    $eyaml      = hiera('r_profile::puppet::master::hiera::eyaml', true),
    $hierarchy  = hiera('r_profile::puppet::master::hiera::hierarchy', $r_profile::puppet::params::hierarchy_default),
) inherits r_profile::puppet::params {
  $hieradir = $r_profile::puppet::params::hieradir
  if $eyaml {
    $backends = [ "eyaml" ]
  } else {
    # [yaml]
    $backends = undef
  }

  class { "hiera":
    hierarchy       => $hierarchy,
    hiera_yaml      => "/etc/puppetlabs/puppet/hiera.yaml",
    datadir         => $hieradir,
    backends        => $backends,
    eyaml           => $eyaml,
    owner           => "pe-puppet",
    group           => "pe-puppet",
    provider        => "puppetserver_gem",
    eyaml_extension => "yaml",
    notify          => Service["pe-puppetserver"],
  }

}
