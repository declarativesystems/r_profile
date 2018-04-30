@test "foo disabled" {
    grep foo "/etc/modprobe.d/blacklist.conf"
}

@test "bar disabled" {
    grep bar "/etc/modprobe.d/blacklist.conf"
}

@test "baz disabled" {
    grep baz "/etc/modprobe.d/blacklist.conf"
}
