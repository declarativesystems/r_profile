# Redhat_tidy::Module_blacklist
#
# Blacklist/disable kernel modules by breaking them in /etc/modeprobe.d/blacklist.conf
#
#
class r_profile::linux::module_disable(
    Array[String] $modules = [],
    $blacklist_file       = "/etc/modprobe.d/blacklist.conf",
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