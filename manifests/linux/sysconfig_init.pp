# @summary Configure `/etc/sysconfig/init`
#
# Lockdown /etc/sysconfig/init settings (RHEL < 7)
# * PROMPT=no
# * SINGLE=/sbin/sulogin
#
# Lockdown /etc/sysconfig/init settings (RHEL >= 7)
# * PROMPT=no
#
# In RHEL7, we must use systemd to configure what happens in single user mode. See r_profile::linux::systemd
# Since umask can be set in many places it has its own profile, see r_profile::linux::umask
#
# @example don't manage the PROMPT variable
#   r_profile::linux::sysconfig_init::manage_prompt: false
#
# @example don't manage the SINGLE variable
#   r_profile::linux::sysconfig_init::manage_single: false
#
# @param manage_prompt Manage the PROMPT variable if true otherwise do nothing
# @param manage_single Manage the SINGLE variable if true otherwise do nothing
# @param manage_umask Manage the umask setting if true otherwise do nothing
# @param umask Value for umask (when managed)
class r_profile::linux::sysconfig_init(
  $manage_prompt  = true,
  $manage_single  = true,
  $manage_umask   = true,
  $umask          = "0027",
) {

  $file = "/etc/sysconfig/init"
  file { $file:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

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

}
