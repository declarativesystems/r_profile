# R_profile::Virtual::vagrant
#
# Support for managing VMs via Vagrant (experimental)
#
# @param puppet_master IP address of puppetmaster (or hostname IF RESOLVABLE)
#   Required if you want to provision an agent on managed VMs automatically,
#   otherwise no agent will be installed
# @param vms Hash of VMs to install in a suitable format for create_resources
#   and `vagrant_vm`
# @param vm_default Hash of default options for `vagrant_vm`
class r_profile::virtual::vagrant(
    $vms            = hiera("r_profile::virtual::vagrant::vms", {}),
    $vm_default     = hiera("r_profile::virtual::vagrant::vm_default", {}),
) {

  include puppet_vagrant::install
  create_resources("vagrant_vm", $vms, $vm_default)
}
