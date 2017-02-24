# R_profile::Software
#
# Install common software if configured
#
# @param packages Array or Hash of packages (suitable for ensure_packages) to
#   install.  Using a hash allows the installation source to be specified,
#   necessary to install package on AIX and Solaris
class r_profile::software(
    $packages = hiera("r_profile::software::packages", {}),
) {

  ensure_packages($packages, {"ensure"=>"present"})
}
