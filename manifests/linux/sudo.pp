# @summary Configure sudo for linux using Puppet
#
# We take a minimal approach to management by just making sure that the package is installed and that the files we want
# to manage exist at /etc/sudoers.d.
#
# This non-destructive approach lets us only manage the sections of configuration we want to
#
# Items to create are grouped into base and non-base to allow easy management in Hiera. Items in non-base can override
# those in base.
#
# @example Profile usage
#   include r_profile::linux::sudo
#
# @example Managing a fragment in /etc/sudoers.d
#   r_profile::linux::sudo::sudoers_d:
#     30_admin: "%admins ALL=(ALL) NOPASSWD: ALL"
#
# @example Managing a fragment in /etc/sudoers.d with multiple lines
#   r_profile::linux::sudo::sudoers_d:
#     40_foobar: |
#       # this is very important to manage foobars
#       %foobar	locahost = (root) NOPASSWD: tail  /var/log/messages
#       %foobar ALL = (root) NOPASSWD:NOEXEC: /usr/bin/vim
#
# @param package Name of the sudo package
# @param sudoers_d_dir Directory where sudoers fragments can be kept
# @param base_sudoers_d Base hash of file content for for files to manage inside the `/etc/sudoers.d`
#   directory
# @param sudoers_d Override hash of file content for for files to manage inside the `/etc/sudoers.d`
#   directory
# @param header Warning message to add to top of files we manage
class r_profile::linux::sudo(
    String                $package        = "sudo",
    String                $sudoers_d_dir  = "/etc/sudoers.d",
    Hash[String, String]  $base_sudoers_d = {},
    Hash[String, String]  $sudoers_d      = {},
    String                $header         = "# This file is managed by Puppet; changes may be overwritten",
) {

  package { $package:
    ensure => present,
  }

  ($base_sudoers_d + $sudoers_d).each |$filename, $content| {
    file { "${sudoers_d_dir}/${filename}":
      ensure  => file,
      owner   => "root",
      group   => "root",
      mode    => "0440",
      content => "${header}\n${content}",
    }
  }
}
