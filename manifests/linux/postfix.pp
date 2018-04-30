# Redhat_tidy::Postfix
#
# Configure postfix for local mail delivery
#
# @param inet_interfaces network interfaces to listen on, becomes inet_interfaces in
#   the main.cf file
class r_profile::linux::postfix(
  $inet_interfaces = "localhost",
) {
  $file = "/etc/postfix/main.cf"

  file_line { "${file} inet_interfaces":
    ensure => present,
    line   => "inet_interfaces = ${inet_interfaces}",
    path   => $file,
    match  => "^inet_interfaces\s*=",
  }
}
