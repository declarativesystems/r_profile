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
# @param hieradir Optionally override the default hieradir directory
class r_profile::puppet::master::hiera(
    $eyaml      = hiera('r_profile::puppet::master::hiera::eyaml', true),
    $hieradir   = $r_profile::puppet::params::hieradir,
) inherits r_profile::puppet::params {

  if $eyaml {
    $backends = [ "eyaml" ]
    # Hiera module will only install eyaml if the manage_package attribute is set,
    # however, setting this also installs the hiera package itself, eg completly
    # breaks puppet enterprise ;-) best thing to do here is install eyaml ourselves
    # and then use the hiera module to finish setting up the hierarchy and eyaml
    # keys.  Note that we have to do this twice - once for vendored ruby and once
    # for vendored jruby.  This isn't need for installations created with
    # puppetizer since it does all this for you...

    # we need a composite namevar to allow this to succeed:
    # http://www.craigdunn.org/2016/07/composite-namevars-in-puppet/
    package { "vendored ruby eyaml":
      ensure   => present,
      name     => "hiera-eyaml",
      provider => puppet_gem,
    }

    package { "vendored jruby eyaml":
      ensure   => present,
      name     => "hiera-eyaml",
      provider => puppetserver_gem,
      notify   => Service['pe-puppetserver'],
    }
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
