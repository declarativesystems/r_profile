# R_profile::Grub2
#
# Secure the grub2 bootloader for RHEL7+
#   * Permissions on main config file
#   * Bootloader passwords set for physical nodes
#
# @param bootloader_users Hash of username -> encrypted password to use for
#   bootloader access on physical machines. Hashed passwords are generated using
#   the `grub2-mkpasswd-pbkdf2` tool. Plaintext passwords are not allowed. To
#   disable password protection, pass `false` here instead
class r_profile::linux::grub2(
    Variant[Boolean, Hash[String,String]] $bootloader_users = {},
) {
  $config_file = "/boot/grub2/grub.cfg"

  file { $config_file:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0600",
  }

  # only set password on physical machines when parameter set
  if $facts['virtual'] == 'physical' {
    if $bootloader_users {
      $users_content = epp("${module_name}/40_custom.epp", {bootloader_users=>$bootloader_users})
    } else {
      $users_content = ""
    }

    # setting the superusers *must* go in 40_custom not 01_users or will get
    # error: "password_pbkdf2: command not found"
    file { "/etc/grub.d/40_custom":
      ensure  => file,
      owner   => "root",
      group   => "root",
      mode    => "0755",
      content => $users_content,
      notify  => Exec["rehash_grub2_config"],
    }
  }

  exec { "rehash_grub2_config":
    refreshonly => true,
    command     => "grub2-mkconfig -o ${config_file}",
    path        => ["/sbin", "/bin","/usr/sbin", "/usr/bin"],
  }

}
