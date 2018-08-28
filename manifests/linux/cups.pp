# @summary Manage cups printers with Puppet
#
# @param printer Hash of printers in a form suitable for create_resources
class r_profile::linux::cups(
    $printer = hiera('r_profile::linux::cups::printer', {}),
) {
  include cups

  Printer {
      require => Class['cups'],
  }
  create_resources('printer', $printer)
}
