# R_Profile::Linux::Module_blacklist
#
# Disable kernel modules by breaking them in `/etc/modeprobe.d/disable.conf`. Kernel modules will be disabled rather
# than blacklisted by this process as `modprobe` will try to load the related file. Since we definie the module as
# `/bin/true`, it won’t be loaded.
#
# @see https://forge.puppet.com/puppetlabs/stdlib
# @see https://linux-audit.com/kernel-hardening-disable-and-blacklist-linux-modules/
#
# @param modules Disable these kernel modules from loading
# @param disable_file File to store the module blacklist in
class r_profile::linux::module_disable(
    Array[String] $modules        = [],
    String        $disable_file = "/etc/modprobe.d/disabled.conf",
) {

  file { $disable_file:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  $modules.each |$module| {

    file_line { "${disable_file} disable_${module}":
      ensure => present,
      path   => $disable_file,
      match  => "^install ${module}",
      line   => "install ${module} /bin/true",
    }
  }

}