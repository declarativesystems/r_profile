# @summary Support for managing files and directories.
#
# Items to create are grouped into base and non-base to allow easy management in
# Hiera. Items in non-base can override those in base.
#
# @example Hiera data to create a directory tree
#   r_profile::file::base_files:
#     "/usr/local":
#       ensure: directory
#       owner: "root"
#       group: "root"
#       mode: "0755"
#     "/usr/local/etc":
#       ensure: directory
#       owner: "root"
#       group: "root"
#       mode: "0755"
#     "/usr/local/bin":
#       ensure: directory
#       owner: "root"
#       group: "root"
#       mode: "0755"
#     "/usr/local/sbin":
#       ensure: directory
#       owner: "root"
#       group: "root"
#       mode: "0755"
#     "/usr/local/share":
#       ensure: directory
#       owner: "root"
#       group: "root"
#       mode: "0755"
#     "/etc/telnet.conf":
#       ensure: absent
#       owner: "root"
#       group: "root"
#       mode: "0755"
#     "/etc/myapp.conf":
#       owner: "root"
#       group: "root"
#       mode: "0644"
#       content: "foo=bar"
#
# @example Hiera data to override/add files
#   r_profile::file::base_files:
#     "/etc/myapp.conf":
#       owner: "root"
#       group: "root"
#       mode: "0644"
#       content: "foo=baz"
#     "/etc/myapp2.conf":
#       owner: "root"
#       group: "root"
#       mode: "0644"
#       content: "foo2=baz2"
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
