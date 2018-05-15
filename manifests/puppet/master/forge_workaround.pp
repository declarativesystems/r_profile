# R_profile::Puppet::Master::Forge_workaround
#
# Puppet Enterprise configures itself using the built-in `puppet_enterprise` module which unfortunately breaks access
# to built-in `pe_r10k` module's support for setting the `forge` directive in `r10k.yaml` to enable system-wide access
# to an alternate Puppet Forge (eg hosted in Satellite, nexus, etc.
#
# This class re-enables this functionality by:
#
# 1.  Gaining access to the parameters of `pe_r10k` set via the `puppet_enterprise::profile::master` class (picks up the
#     settings from the node classifier
# 2.  Copy-paste the logic from `pe_r10k::config` for setting `$_sources`
# 3.  With the fixed up variable `forge_settings` in scope, Collect the `r10k.yaml` file and re-evaluate its template
#
# `chattr`/`lsattr` are used to turn off the immutable bit which may have been set while configuring r10k on first boot
# to allow the inital code deploy which would include this class. Puppet is not able to alter files that are marked
# immutable
#
# @example hiera data
#   r_profile::puppet::master::forge_workaround::forge_settings:
#     baseurl: 'https://private-forge.mysite'
#
# ...results in:
#   forge:
#     baseurl: 'https://private-forge.mysite'
#
#
# @param forge_settings Hash of forge settings to configure global r10k. You shouldn't need to alter the remaining
#   settings as these are resolved: node classifier -> class resource (puppet_enterprise::profile::master) -> class
#   resource (pe_r10k) -> inherted current value
class r_profile::puppet::master::forge_workaround(
  $forge_settings   = {},
  $cachedir         = $pe_r10k::cachedir,
  $proxy            = $pe_r10k::proxy,
  $remote           = $pe_r10k::remote,
  $sources          = $pe_r10k::sources,
  $git_settings     = $pe_r10k::git_settings,
  $deploy_settings  = $pe_r10k::deploy_settings,
  $postrun          = $pe_r10k::postrun,
  $r10k_basedir     = $pe_r10k::r10k_basedir,
) inherits pe_r10k {

  package { "e2fsprogs":
    ensure => present,
  }

  exec { "remove immutable from r10k.yaml":
    command => "chattr -i /etc/puppetlabs/r10k/r10k.yaml",
    onlyif  => "lsattr /etc/puppetlabs/r10k/r10k.yaml |grep -- ----i-----------",
    path    => "/bin",
    before  => File["r10k.yaml"]
  }

  # duplicated logic from pe_r10k::config
  if $sources {
    pe_validate_hash($sources)
    $_sources = $sources
  }
  elsif $remote {
    pe_validate_absolute_path($r10k_basedir)

    pe_validate_string($remote)

    $_sources = {
      'puppet' => {
        'remote'  => $remote,
        'basedir' => $r10k_basedir,
      },
    }
  }
  else {
    $_sources = {}
  }

  # re-process the template in *this* scope, with our local variable
  File <| title == "r10k.yaml" |> {
    content => template('pe_r10k/r10k.yaml.erb'),
  }
}
