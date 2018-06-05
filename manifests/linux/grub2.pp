# R_profile::Grub2
#
# Secure the grub2 bootloader for RHEL7+
#   * Permissions on main config file
#   * Bootloader passwords set for physical nodes
#
# @example Hiera data with encrypted bootloader passwords
#   r_profile::linux::grub2::bootloader_users:
#     admin: "grub.pbkdf2.sha512.10000.D6956EF5CB5A4A4C67D72332F71FD62E8AC5FBF45723D2F658B846E554D031D3B56325CDFAF1854B\
#       C6F98B0967023236B99C1B23BD058F47AD3C2891EBA03D35.91DD3B5338F287A8CCE20D665E0003F379C65724FE6833AE7B1CD1C0EB42A4\
#       F9A03393F2C74F7D003E7A178DC475DBFD0FD501370DA60B4734BDF20872B2D314"
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
