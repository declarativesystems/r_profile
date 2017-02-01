# R_profile::Linux::Selinux
#
# Managment of SELinux and optional removal of the setroubleshoot debug package
#
# @param sel_mode Enforcment of the SELinux mode to apply to this node.  noop means
#   leave the current SELinux mode alone, the remaining allowed values force the
#   SELinux mode to be enforced as requested.  Don't forget that you usually have
#   to reboot after changing the mode.  To avoid accidentally rebooting systems
#   this module does not do this for you. 
class r_profile::linux::selinux(
    Enum['noop', 'enforcing', 'permissive', 'disabled'] $sel_mode =
      hiera("r_profile::linux::selinux::mode", 'noop'),
    Boolean $remove_troubleshoot =
      hiera("r_profile::linux::selinux::remove_troubleshoot", false),
) {

  if $sel_mode != "noop" {
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
}
