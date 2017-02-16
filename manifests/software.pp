# Install common software if configured
#
# Params
# [*packages*]
#   Hash of packages to install
class r_profile::software(
    $packages = hiera("r_profile::software::packages", {}),
) {

  ensure_packages($packages, {"ensure"=>"present"})
}
