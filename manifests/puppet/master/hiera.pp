class r_profile::puppet::master::hiera(
    $eyaml      = hiera('puppet::master::hiera::eyaml', true),
    $hierarchy  = hiera('puppet::master::hiera::hierarchy', $r_profile::puppet::params::hierarchy_default),
) inherits r_profile::puppet::params {
  $hieradir = $r_profile::puppet::params::hieradir
  if $eyaml {
    $backends = [ "eyaml" ]
  } else {
    $backends = [ "hiera" ]
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
