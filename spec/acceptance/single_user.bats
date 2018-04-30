@test "sulogin in emegency.service" {
    grep sulogin /usr/lib/systemd/system/emergency.service
}

@test "sulogin in rescue.service" {
    grep sulogin /usr/lib/systemd/system/rescue.service
}