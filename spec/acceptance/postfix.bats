@test "inet_interfaces set correctly" {
  grep '^inet_interfaces = localhost' /etc/postfix/main.cf
}
