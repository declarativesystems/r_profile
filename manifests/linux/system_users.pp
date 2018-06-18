# R_profile::Linux::System_users
#
# Lockdown and restrict users across the system:
# * disable _system_ accounts (UID < 500/1000) by locking the shell
# * ensure root group is 0
# * lock inactive users
#
# @see https://forge.puppet.com/geoffwilliams/system_users
#
# @example class usage
#   include r_profile::linux::system_users
#
# @example Hiera data to lock low_uids
#   r_profile::linux::system_users::uid_range: 'low_uids'
#
# system users (`system_uids` - uid < 1000)
# - or -
# low uid users (`low_uids` - uid < 500)
#
# @param uid_range Range of UIDs to lockdown (see above)
class r_profile::linux::system_users(
    Enum['low_uids', 'system_uids'] $uid_range = 'system_uids',
) {
  class { "system_users::disable_system_account":
    uid_range => $uid_range,
  }
  include system_users::root_group
  include system_users::lock_inactive

}