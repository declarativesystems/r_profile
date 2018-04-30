# Redhat_tidy::Password_policy
#
# Enforce password quality settings
# * password max days
# * password warn age
# * password algorithm
#
# @param pass_max_days maximum age of a password
# @param pass_warn_age how long to warn before password expires
# @param password_algorithm password algorithm to use
# @param saved_passwords how many old passwords to remember?
# @param manage_authconfig True to install `authconfig`, otherwise assume its
#   already on the system. `authconfig` command is required inspect the password
#   settings that apply on this system
class r_profile::linux::password_policy(
    String  $pass_max_days       = "90",
    String  $pass_warn_age       = "7",
    String  $password_algorithm  = "sha512",
    String  $saved_passwords     = "4",
    Boolean $manage_authconfig   = true,
) {

  if $manage_authconfig {
    package { "authconfig":
      ensure => present,
    }
  }

  file_line { "/etc/login.defs PASS_MAX_DAYS":
    ensure => present,
    path   => "/etc/login.defs",
    match  => "^PASS_MAX_DAYS",
    line   => "PASS_MAX_DAYS ${pass_max_days}",
  }

  file_line { "/etc/login.defs PASS_WARN_AGE":
    ensure => present,
    path   => "/etc/login.defs",
    match  => "^PASS_WARN_AGE",
    line   => "PASS_WARN_AGE 90",
  }

  exec { "authconfig password algorithm":
    command => "authconfig --passalgo=${password_algorithm} --update",
    unless  => "authconfig --test | awk '/hashing/ {print \$5}' | grep ${password_algorithm}",
    path    => ["/usr/bin", "/usr/sbin", "/bin", "/sbin"],
  }

  # how many old passwords to remember?
  #
  # Note:  The vagrant box used for testing had duplicate entries in
  # /etc/pam.d/system-auth that were enough to break idempotency:
  #  password    sufficient    pam_unix.so
  #  password     sufficient   pam_unix.so
  # Note 'off' spacing which suggests added by a build script...  This suggests
  # that such entries are not normally present.  To resolve the condition, the
  # duplicate entry was manually removed and the resource was then processed
  # idempotently.
  pam { "system-auth password sufficient pam_unix.so remember":
    ensure    => present,
    service   => 'system-auth',
    type      => 'password',
    control   => 'sufficient',
    module    => 'pam_unix.so',
    arguments => "remember=${saved_passwords}",
    position  => 'before module pam_deny.so',
  }

  # su access for members of wheel (uncomment existing rule in stock file), needs
  # different position for rhel 7 vs 6
  if $facts['os']['release']['major'] == "7" {
    $condition = 'before *[type="auth" and control="substack"]'
  } else {
    $condition = 'before *[type="auth" and control="include"]'
  }
  pam { "su auth required pam_wheel.so use_uid":
    ensure    => present,
    service   => 'su',
    type      => 'auth',
    control   => 'required',
    module    => 'pam_wheel.so',
    arguments => 'use_uid',
    position  => $condition,
  }
}
