# @summary Purge the passed-in packages from the system
#
# @example Hiera data
#   r_profile::lockdown::package::delete:
#     - ypserv
#     - talk-server
#     - ["Server with GUI", yum_group]
#
# @example Declaration
#   include r_profile::lockdown::package
#
# @param delete Array of packages to remove. If you need to specify a provider to remove a particular type of package
#   (gem, egg, yum_group, etc.) then specify an array containing package name and provider (see example)
class r_profile::lockdown::package(
    Array[Variant[String, Array[String]]] $delete = hiera("r_profile::lockdown::package::delete", [])
) {

  $delete.each |$element| {
    # split each package into an array of [packagename, provider] or just [packagename] if no provide needed

    # https://tickets.puppetlabs.com/browse/MODULES-6534
    $package = Array($element, true)
    if length($package) == 2 {
      $provider = $package[1]
    } else {
      $provider = undef
    }

    package { $package[0]:
      ensure   => purged,
      provider => $provider
    }
  }
}
