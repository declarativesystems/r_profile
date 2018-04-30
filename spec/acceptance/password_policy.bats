@test "system-auth sufficient pam_unix.so remember set" {
  grep 'password[[:space:]]*sufficient[[:space:]]*pam_unix.so[[:space:]]*remember=' /etc/pam.d/system-auth
}

@test "auth required pam_wheel.so use_uid set" {
  grep 'auth[[:space:]]*required[[:space:]]*pam_wheel.so[[:space:]]*use_uid' /etc/pam.d/su
}
