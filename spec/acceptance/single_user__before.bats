@test "emergency testcase setup ok" {
    grep bash /usr/lib/systemd/system/emergency.service
}

@test "rescue testcase setup ok" {
    grep bash /usr/lib/systemd/system/rescue.service
}