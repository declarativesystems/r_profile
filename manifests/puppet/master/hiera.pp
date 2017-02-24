# R_profile::Puppet::Master::Hiera
#
# Configure a custom hierarchy and setup hiera-eyaml
#
# End users are able to customise their hierarchy completly by specifying it in
# in its entirety in a file called `hierarchy.txt` in production hieradata
# directory within the control repository (final file location on Puppet Master:
# `/etc/puppetlabs/code/environments/production/hieradata/hierarchy.txt`).
#
# Each line in the file will be taken verbatim to form a level of the
# `:hierarchy:` key in specified in `hiera.yaml`.  Eg, a file with the content:
#
# ```
# "node/%{clientcert}"
# "os/%{osfamily}_%{operatingsystemmajrelease}"
# "common"
# ```
#
# Would be rewritten in `hiera.yaml` as:
#
# ```yaml
#:hierarchy:
#  - "node/%{::trusted.certname}"
#  - "os/%{osfamily}_%{operatingsystemmajrelease}"
#  - "common"
# ```
#
# If the `hierarchy.txt` file is not available, then a default hierarchy sourced
# from `params.pp` will be used instead.
#
# `hiera-eyaml` Will be automatically configured unless you have told this
# profile not to, which may be necessary where there is limited internet
# connectivity or http proxies in use.
#
# @param eyaml True to attempt to install and configure hiera-eyaml, otherwise do
#   nothing @see https://github.com/TomPoulton/hiera-eyaml
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

  # read from /dev/null to prevent error if file is not present.  This allows
  # easy fallback to the default hierachy in params.pp
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
