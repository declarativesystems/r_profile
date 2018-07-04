# R_profile::File
#
# Support for managing files and directories.
#
# Items to create are grouped into base and non-base to allow easy management in Hiera. Items in non-base can override
# those in base.
#
# @param base_files Hash of files to create (suitable for `file` resource)
# @param files Hash of files to create (suitable for `file` resource)
class r_profile::file(
  Hash[String, Hash[String,Any]]  $base_files       = {},
  Hash[String, Hash[String,Any]]  $files            = {},
) {

  ($base_files + $files).each |$title, $opts| {
    file {
      default:
        ensure => file,
      ;
      $title:
        * => $opts,
    }
  }
}
