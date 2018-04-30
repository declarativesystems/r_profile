# Redhat_tidy::Module_blacklist
#
# Blacklist/disable kernel modules by breaking them in /etc/modeprobe.d/blacklist.conf
#
#
class r_profile::linux::module_disable(
    Array[String] $disable_modules = [],
    $blacklist_file       = "/etc/modprobe.d/blacklist.conf",
) {

  file { $blacklist_file:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  $disable_modules.each |$disable_module| {

    file_line { "${blacklist_file} disable_${disable_module}":
      ensure => present,
      path   => $blacklist_file,
      match  => "^install ${disable_module}",
      line   => "install ${disable_module} /bin/true",
    }
  }

}