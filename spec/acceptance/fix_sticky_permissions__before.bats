@test "fixed permissions on /abc" {
 [[ $(stat -c %a /abc) == "777" ]]
}
