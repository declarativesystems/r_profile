# R_profiles::mount
#
# Configure filesystem mounts using the puppet built-in mount provider.
# @see https://puppet.com/docs/puppet/5.5/types/mount.html
#
# @example mounting a partition on `/opt`
#   r_profile::mount::mount:
#     '/opt':
#       ensure: mounted
#       atboot: true
#       options: 'nodev'
#       device: '/dev/sdc1'
#       fstype: ext4
#
# @param mount hash of mounts to mount
# @param default hash of default mount options
class r_profile::mount($mount={}, $default={}) {
  $mount.each |$key, $opts| {
    mount {
      default:
        * => $default,
      ;
      $key:
        * => $opts
      ;
    }
  }
}
