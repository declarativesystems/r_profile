# R_profile::Linux::Package_manager
#
# Configure a linux package manager
class r_profile::linux::package_manager {
  case $osfamily {
    "RedHat": {
      include r_profile::linux::yum
    }
    "Debian": {
      include r_profile::linux::apt
    }
    default: {
      notify { "No support for setting up package manager on ${osfamily}": }
    }
  }


}
