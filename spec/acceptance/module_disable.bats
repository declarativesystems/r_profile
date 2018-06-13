@test "foo disabled" {
    grep foo "/etc/modprobe.d/disabled.conf"
}

@test "bar disabled" {
    grep bar "/etc/modprobe.d/disabled.conf"
}

@test "baz disabled" {
    grep baz "/etc/modprobe.d/disabled.conf"
}
