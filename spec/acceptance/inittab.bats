@test "inittab set correctly" {
  grep 'id:3:initdefault:' /etc/inittab
}
