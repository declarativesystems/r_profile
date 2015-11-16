# Glue profile to configure the puppetlabs vsphere module and then create
# any VMs listed in heira.  If none are listed, attempt to create an vms from
# a list of zero targets (the empty has on the `vsphere_vms` hash - do nothing)
#
# params
# [*vcenter_host*]
#   hostname or IP address of vcenter server
# [*vcenter_user*]
#   user to login to vcenter as
# [*vcenter_password*]
#   Password to login to vcenter with
# [*vcenter_port*]
#   Port for vcenter API
# [*vsphere_defaults*]
#   Hash of default options for `vsphere_vm` resources.  Defaults to empty
#   hash (no default options) if nothing found in hiera
# [*vsphere_vms*]
#   Has of VM images to create defaults to empty hash (no VMs if nothing found
#   in hiera)
class r_profile::vsphere(
    $vcenter_host     = hiera("r_profile::vsphere::vcenter_host"),
    $vcenter_user     = hiera("r_profile::vsphere::vcenter_user"),
    $vcenter_password = hiera("r_profile::vsphere::vcenter_password"),
    $vcenter_port     = hiera("r_profile::vsphere::vcenter_port"),
    $vsphere_defaults = hiera("r_profile::vsphere::vsphere_defaults", {}),
    $vsphere_vms      = hiera("r_profile::vsphere::vsphere_vms", {}),
) {

  validate_hash($vsphere_defaults)
  validate_hash($vsphere_vms)

  # setup packages and vsphere.conf file
  class { "vsphere_support":
    vcenter_host     => $vcenter_host,
    vcenter_user     => $vcenter_user,
    vcenter_password => $vcenter_password,
    vcenter_port     => $vcenter_port,
  }

  create_resources("vsphere_vm", $vsphere_vms, $vsphere_defaults)
}
