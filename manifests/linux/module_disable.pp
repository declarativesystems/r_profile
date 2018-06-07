# R_Profile::Linux::Module_blacklist
#
# Blacklist/disable kernel modules by breaking them in `/etc/modeprobe.d/blacklist.conf`. Kernel modules will be
# completely disabled by this process as `modprobe` will try to load the related file. Since we cefinie the module as
# `/bin/true`, it won’t be loaded.
#
# @see https://forge.puppet.com/puppetlabs/stdlib
# @see https://linux-audit.com/kernel-hardening-disable-and-blacklist-linux-modules/
#
# @param modules Disable these kernel modules from loading
# @param blacklist_file File to store the module blacklist in
class r_profile::linux::module_disable(
    Array[String] $modules        = [],
    String        $blacklist_file = "/etc/modprobe.d/blacklist.conf",
) {

  file { $blacklist_file:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  $modules.each |$module| {

    file_line { "${blacklist_file} disable_${module}":
      ensure => present,
      path   => $blacklist_file,
      match  => "^install ${module}",
      line   => "install ${module} /bin/true",
    }
  }

}