# @summary Configure the `wheel` group on Linux
#
# @param gid GID of the wheel group, normally 10
# @param wheel_su `present` to ensure wheel group required for `su` access, `absent` to allow anyone
class r_profile::linux::wheel(
    Integer                   $gid      = 10,
    Enum['present', 'absent'] $wheel_su = 'present',
) {

  group { "wheel":
    ensure => present,
    gid    => $gid,
  }

  # only allow users in the wheel group to execute `su`
  pam { "su pam_wheel.so":
    ensure    => $wheel_su,
    service   => 'su',
    type      => 'auth',
    control   => 'required',
    module    => 'pam_wheel.so',
    arguments => "use_uid",
    position  => 'after module pam_rootok.so',
  }
}