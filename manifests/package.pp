# R_profile::Package
#
# Install software using Puppet's built-in `package` resource.
#
# @see https://puppet.com/docs/puppet/5.5/types/package.html
#
# @example Hiera data for installing packages
#   r_profile::package::packages:
#     tree:
#     samba:
#
# @example Hiera data to removing packages
#   r_profile::package::packages:
#     telnet:
#       ensure: absent
#
# @example Hiera data to install a particular version of a package
#   r_profile::package::packages:
#     "java-1.8.0-openjdk":
#       ensure: "1.8.0.171-8.b10.el7_5"
#
# @param packages Array or Hash of packages (suitable for ensure_packages) to
#   install.  Using a hash allows the installation source to be specified,
#   necessary to install package on AIX and Solaris
class r_profile::package(
    Hash[String, Optional[Hash]] $packages = {},
) {

  $packages.each | $key, $opts | {
    package {
      default:
        ensure => present,
      ;
      $key:
        * => pick($opts, {})
    }
  }
}
