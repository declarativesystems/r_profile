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
    $puppet_master  = hiera("r_profile::virtual::vagrant::puppet_master", false),
    $vms            = hiera("r_profile::virtual::vagrant::vms", {}),
    $vm_default     = hiera("r_profile::virtual::vagrant::vm_default", {}),
) {

  include puppet_vagrant::install

  if $puppet_master {
    $provision = "curl -k https://${puppet_master}:8140/packages/current/install.bash | sudo bash"
  } else {
    $provision = ""
  }

  $vms.each |$vm_title, $vm_params| {
    vagrant_vm { $vm_title:
      ensure    => pick($vm_params["ensure"], $vm_default["ensure"]),
      box       => pick($vm_params["box"], $vm_default["box"]),
      memory    => pick($vm_params["memory"], $vm_default["memory"], false),
      cpu       => pick($vm_params["cpu"], $vm_default["cpu"], false),
      provision => pick($vm_params["provision"], $vm_default["provision"], $provision),
      ip        => pick($vm_params["ip"], $vm_default["ip"], false),
      # not implemented yet user          => "vagrant",
    }
  }


}
