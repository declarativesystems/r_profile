# r_profile::linux::Mounts
#
# Common mount good practices for RedHat:
#   * `/tmp` mounted `nodev,nosuid,noexec` (if separate partition)
#   * `/dev/shm` mounted `nodev,nosuid,noexec` (if separate partition)
#   * `/home` mounted `nodev` (if separate partition)
#   * Optionally bind mount `/var/tmp` to `/tmp`
#   * Ensure additional `mounts` are present in `/etc/fstab` and mounted
#
# @see https://puppet.com/docs/puppet/5.5/types/mount.html
#
# @example hiera data to enable bind mounting /tmp
#   r_profile::linux::mounts::bind_mount_var_tmp: true
#
# @example hiera data to ensure additional mounts (options are those provided by `mount` provider)
#   r_profile::linux::mounts::mounts:
#     "/data":
#       atboot: true
#       device: /dev/sdc1
#       fstype: ext4
#     "/cdrom":
#       ensure: absent
#
# @param bind_mount_var_tmp `true` to bind mount `/var/tmp` to `/tmp`
# @param mounts Hash of extra mountpoints to mount (see examples)
class r_profile::linux::mounts(
    Boolean                       $bind_mount_var_tmp = false,
    Hash[String, Optional[Hash]]  $mounts             = {}
) {
  if dig($facts, 'mountpoints', '/tmp') {
    mount { '/tmp':
      ensure  => mounted,
      atboot  => true,
      options => 'nodev,nosuid,noexec',
      device  => $facts['mountpoints']['/tmp']['device'],
      fstype  => $facts['mountpoints']['/tmp']['filesystem'],
    }
  }

  if dig($facts, 'mountpoints', '/dev/shm') {
    mount { '/dev/shm':
      ensure  => mounted,
      atboot  => true,
      options => 'nodev,nosuid,noexec',
      device  => $facts['mountpoints']['/dev/shm']['device'],
      fstype  => $facts['mountpoints']['/dev/shm']['filesystem'],
    }
  }

  if dig($facts, 'mountpoints', '/home') {
    mount { '/home':
      ensure  => mounted,
      atboot  => true,
      options => 'nodev',
      device  => $facts['mountpoints']['/home']['device'],
      fstype  => $facts['mountpoints']['/home']['filesystem'],
    }
  }

  if $bind_mount_var_tmp {
    file { "/var/tmp":
      ensure => directory,
      owner  => root,
    }
    mount { '/var/tmp':
      ensure  => mounted,
      device  => '/tmp',
      fstype  => 'none',
      options => 'bind,nodev,nosuid,noexec',
    }
  }

  $mounts.each |$key, $opts| {
    mount {
      default:
        ensure => mounted,
      ;
      $key:
        * => pick($opts, {})
    }
  }
}
