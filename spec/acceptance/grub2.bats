@test "permissions on main config file" {
  [[ $(stat -c %a /boot/grub2/grub.cfg) == "600" ]]
}

@test "file rehashed and superuser created" {
  grep admin /boot/grub2/grub.cfg
}

@test "file rehashed and password set" {
  grep "password_pbkdf2 admin" /boot/grub2/grub.cfg
}
