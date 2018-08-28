# @summary Manage SELinux
#
# Features:
#   * Set SELinux enforcement mode
#   * Remove the setroubleshoot debug package (optional)
#   * Set selinux booleans (`setsebool`)
#
# @see https://forge.puppet.com/puppet/selinux/issues
#
# @example Basic usage
#   include r_profile::linux::selinux
#
# @example Turn off SELinux
#   r_profile::linux::selinux::sel_mode: "disabled"
#
# @example Remove the debug package
#   r_profile::linux::selinux::remove_troubleshoot: true
#
# @example Enforce `setsebool` settings
#   r_profile::linux::selinux::sebools:
#     haproxy_connect_any: 1
#
# @param sel_mode Enforcment of the SELinux mode to apply to this node.  `undef` means
#   leave the current SELinux mode alone, the remaining allowed values force the
#   SELinux mode to be enforced as requested.  Don't forget that you usually have
#   to reboot after changing the mode.  To avoid accidentally rebooting systems
#   this module does not do this for you.
# @param remove_troubleshoot true to remove the setroubleshoot package, false to
#   leave it alone
# @param sebools Hash of sebool values to enforce (see examples)
class r_profile::linux::selinux(
    Optional[Enum["enforcing", "permissive", "disabled"]] $sel_mode             = undef,
    Boolean                                               $remove_troubleshoot  = false,
    Hash[String,Optional[Hash]]                           $sebools              = {}
) {

  if $sel_mode {
    # if we have been requested to reconfigure SELinux, do so...
    class { "selinux":
      mode => $sel_mode,
    }
  }

  if $remove_troubleshoot {
    # Remove setroubleshoot if we have been requested to
    package { "setroubleshoot":
      ensure => absent,
    }
  }

  $sebools.each |$key, $opts| {
    selinux::boolean {
      default:
        ensure => "on",
      ;
      $key:
        * => $opts,
    }
  }
}
