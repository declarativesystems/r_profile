# @summary Install Oracle VirtualBox
# @see https://forge.puppet.com/puppet/virtualbox
#
# @param version Version to install, installs latest if unspecified
class r_profile::virtual::virtual_box(
  Optional[String] $version = undef,
) {

  include r_profile::linux::kernel_devel

  class { "virtualbox":
    version => $version,
  }
}
