# @summary Setup chocolatey package manager on Windows
#
# @see https://forge.puppet.com/puppetlabs/chocolatey
# @see https://forge.puppet.com/puppet/windows_env
#
# @example Basic usage
#   include r_profile::windows::chocolatey
#
# @example Chocolatey settings
#   r_profile::windows::chocolatey:
#     settings:
#       chocolatey_download_url: 'https://internalurl/to/chocolatey.nupkg'
#       use_7zip: false
#       choco_install_timeout_seconds: 2700
#
# @example Purge unmanaged package sources
#   r_profile:windows::chocolatey::purge_sources: true
#
# @example Setting up package sources
#   r_profile::windows::chocolatey::sources
#     megacorp_chocolatey:
#       location => 'https://repo.megacorp.com/artifactory/chocolatey'
#       user     => 'deploy'
#       password => 'tops3cret'
#
# @example Disable configuring chocolatey as default package provider
#   r_profile::windows::chocolatey::default_provider: false
#
# @param settings
#   Hash of settings to pass to main chocolatey installer module (see example)
# @param purge_sources
#   `true` to purge any unmanaged package sources from chocolatey, otherwise
#   `false` to allow end-user management of non-puppet managed sources
# @param sources
#   Chocolatey package sources installed by Puppet (see example)
class r_profile::windows::chocolatey(
    Hash[String,Any]  $settings         = {},
    Boolean           $purge_sources    = false,
    Hash[String, Any] $sources          = {},
    Boolean           $default_provider = true,
) {

  resources { "chocolateysource":
    purge => $purge_sources,
  }

  $sources.each |$key, $opts| {
    chocolateysource {
      default:
        ensure => enabled,
      ;
      $key:
        * => $opts,
    }
  }

  class {'chocolatey':
    * => $settings,
  }

  # Chocolatey is not the default package provider on windows so set it here
  # https://tickets.puppetlabs.com/browse/MODULES-3597
  if $default_provider {
    # Rely on autotagging behaviour to select the commands that chocolatey
    # class would have run since we can't collect classes
    Exec <| tag == "chocolatey::install" or tag == "chocolately::config"|>
    -> Package <| provider == undef |> {
      provider => chocolatey
    }

  }
}
