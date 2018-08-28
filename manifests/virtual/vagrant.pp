# @summary Support for managing VMs via Vagrant (experimental)
#
# @param vms Hash of VMs to install in a suitable format for create_resources
#   and `vagrant_vm`
# @param vm_default Hash of default options for `vagrant_vm`
class r_profile::virtual::vagrant(
    Hash $vms            = {},
    Hash $vm_default     = {},
) {

  include puppet_vagrant::install
  $vms.each |$key, $opts| {
    vagrant_vm { $key:
      * => $opts
    }
  }

}
