# R_profile::Linux::Sysconfig_init
#
# Lockdown /etc/sysconfig/init settings (RHEL < 7)
# * PROMPT=no
# * SINGLE=/sbin/sulogin
# * umask 027
#
# Lockdown /etc/sysconfig/init settings (RHEL >= 7)
# * PROMPT=no
# * umask 0027
#
# In RHEL7, we must use systemd to configure what happens in single user mode. See r_profile::linux::systemd
#
# @example don't manage the PROMPT variable
#   r_profile::linux::sysconfig_init::manage_prompt: false
#
# @example don't manage the SINGLE variable
#   r_profile::linux::sysconfig_init::manage_single: false
#
# @example don't manage umask
#   r_profile::linux::sysconfig_init::manage_umask: false
#
# @example enforce a more relaxed umask
#   r_proflie::linux::sysconfig_init::umask: 0022
#
# @param manage_prompt Manage the PROMPT variable if true otherwise do nothing
# @param manage_single Manage the SINGLE variable if true otherwise do nothing
# @param manage_umask Manage the umask setting if true otherwise do nothing
# @param umask Octal umask (as string) to enforce if manage_umask is also true
class r_profile::linux::sysconfig_init(
  $manage_prompt  = true,
  $manage_single  = true,
  $manage_umask   = true,
  $umask          = "0027",
) {

  $file = "/etc/sysconfig/init"

  # PROMPT=no
  if $manage_prompt {
    file_line { "${file} PROMPT":
      ensure => present,
      line   => "PROMPT=no",
      match  => "^PROMPT=",
      path   => $file,
    }
  }

  # SINGLE=/sbin/sulogin
  if $manage_single {
    file_line { "${file} SINGLE":
      ensure => present,
      line   => "SINGLE=/sbin/sulogin",
      match  => "^SINGLE=",
      path   => $file,
    }
  }

  if $manage_umask {
    # SINGLE=/sbin/sulogin
    file_line { "${file} umask":
      ensure => present,
      line   => "umask ${umask}",
      match  => "^umask ",
      path   => $file,
    }
  }
}
