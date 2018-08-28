# @summary Common mount good practices for RedHat
#
# Features:
#   * `/tmp` mounted `nodev,nosuid,noexec` (if separate partition)
#   * `/dev/shm` mounted `nodev,nosuid,noexec` (if separate partition)
#   * Optionally bind mount `/var/tmp` to `/tmp`
#   * All partitions except `/` mounted with `nodev` option
#
# Note that options for `/dev/shm` will be ignored as per https://bugzilla.redhat.com/show_bug.cgi?id=783884
#
# Puppet provides a `mountpoint` fact with output similar to:
#   /home => {
#     available => "19.97 GiB",
#     available_bytes => 21438976000,
#     capacity => "0.16%",
#     device => "/dev/mapper/centos-home",
#     filesystem => "xfs",
#     options => [
#       "rw",
#       "seclabel",
#       "relatime",
#       "attr2",
#       "inode64",
#       "noquota"
#     ],
#     size => "20.00 GiB",
#     size_bytes => 21472735232,
#     used => "32.20 MiB",
#     used_bytes => 33759232
#   },
#
# This is completely different to the input the `mount` provider uses:
#   mount { '/home':
#     ensure  => 'mounted',
#     device  => '/dev/mapper/centos-home',
#     dump    => '0',
#     fstype  => 'xfs',
#     options => 'defaults',
#     pass    => '0',
#     target  => '/etc/fstab',
#   }
#
# Since the `mountpoint` fact does not include the current ensure, this profile uses a new
# fact `fstab` which includes the content of `/etc/fstab` validated against `/proc/mounts` and
# excluding any swap partitions:
#   /home => {
#     ensure => "mounted",
#     device => "/dev/mapper/centos-home",
#     fstab => "xfs",
#     options => "defaults",
#     dump => "0",
#     pass => "0"
#   }
#
# @see https://puppet.com/docs/puppet/5.5/types/mount.html
#
# @example hiera data to enable bind mounting /tmp
#   r_profile::linux::mount::bind_mount_var_tmp: true
#
# @param bind_mount_var_tmp `true` to bind mount `/var/tmp` onto `/tmp` if
#   `/var/tmp` is not _already_ a separately mounted partition
class r_profile::linux::mount(
    Boolean $bind_mount_var_tmp = false,
) {

  if $bind_mount_var_tmp and ! dig($facts, 'fstab', '/var/tmp'){
    file { "/var/tmp":
      ensure => directory,
      owner  => root,
    }
    mount { '/var/tmp':
      ensure  => mounted,
      atboot  => true,
      device  => '/tmp',
      fstype  => 'none',
      options => 'bind',
    }
  }

  pick($facts['fstab'], {}).each |$key, $opts| {
    # leave root filesystem and bind mounts alone
    if $key != "/" and ! ($opts['options'] =~ /bind/) {

      if $key == '/tmp' {
        # special handling for /tmp - should always just be
        $mount_options = "nodev,nosuid,noexec"
      } elsif ! ($opts['options'] =~ /nodev/) {
        # for all other mount points, make sure that we add the nodev option
        $mount_options = "${opts['options']},nodev"
      } else {
        # otherwise we are already setup how we should be
        $mount_options = $opts['options']
      }


      mount { $key:
        options => $mount_options,
      }
    }
  }

}
