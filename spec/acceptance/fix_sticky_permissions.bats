@test "bad permissions on /abc" {
 [[ $(stat -c %a /abc) == "1777" ]]
}
