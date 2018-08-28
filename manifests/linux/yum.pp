# @summary Common yum settings for RedHat
#
# @param gpgcheck 1 to enable gpg checks otherwise false
# @param protected_multilib 1 to protect against installing 'multilib' libraries
#   (Libraries from architectural variants)
class r_profile::linux::yum(
  $gpgcheck           = '1',
  $protected_multilib = '1',
) {

  file_line { "yum.conf gpgcheck":
    ensure => present,
    line   => "gpgcheck=${gpgcheck}",
    match  => "gpgcheck=",
    path   => "/etc/yum.conf",
  }

  file_line { "yum.conf protected_multilib":
    ensure => present,
    line   => "protected_multilib=${protected_multilib}",
    match  => "protected_multilib=",
    path   => "/etc/yum.conf",
  }
}
