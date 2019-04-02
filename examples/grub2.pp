# @PDQTest
class { "r_profile::linux::grub2":
  bootloader_users => {
    "admin" => "grub.pbkdf2.sha512.10000.DEADBEEF"
  }
}
