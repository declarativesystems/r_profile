@test "inittab set to 5" {
  grep 'id:5:initdefault:' /etc/inittab
}
