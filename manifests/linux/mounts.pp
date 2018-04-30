# Redhat_tidy::Mounts
#
# Common mount good practices for RedHat
class r_profile::linux::mounts {
  if dig($facts, 'mountpoints', '/tmp') {
    mount { '/tmp':
      ensure  => mounted,
      atboot  => true,
      options => 'nosuid,noexec',
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

}
