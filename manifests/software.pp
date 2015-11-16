# Install common software if configured
#
# Params
# [*packages*]
#   Array of packages to install
class r_profile::software(
    $packages = hiera("r_profile::software::packages", []),
) {

  if $packages {
    package { $packages:
      ensure => present,
    }
  }
}
