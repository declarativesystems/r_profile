# R_profile::Virtual::Virtual_box
#
# Install Oracle VirtualBox using the voxpupuli virtualbox module.
# @see https://forge.puppet.com/puppet/virtualbox
#
# @param version Version to install, installs latest if unspecified
class r_profile::virtual::virtual_box(
  $version = hiera("r_profile::virtual::virtual_box", undef)
) {

  class { "virtualbox":
    version => $version,
  }
}
