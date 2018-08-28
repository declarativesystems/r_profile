# @summary Configure a system for kernel compilation
#
# Currently suported:
# * RedHat
class r_profile::linux::kernel_devel {
  package { "kernel-devel-${kernelrelease}":
    ensure => present,
  }
}
