# R_profile::Puppet::Master::Hiera
#
# Configure hiera based on passed-in hierachy
class r_profile::puppet::master::hiera(
    $eyaml      = hiera('r_profile::puppet::master::hiera::eyaml', true),
) inherits r_profile::puppet::params {
  $hieradir = $r_profile::puppet::params::hieradir
  if $eyaml {
    $backends = [ "eyaml" ]
  } else {
    # [yaml]
    $backends = undef
  }

  # fixme - pick vs params
  $hierarchy_raw = file(
    "/etc/puppetlabs/code/environments/production/hieradata/hierarchy.txt",
    "/dev/null"
  )
  if $hierarchy_raw == "" {
    $hierarchy = $hierarchy_default
  } else {
    $hierarchy = split($hierarchy_raw, '\n')
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
