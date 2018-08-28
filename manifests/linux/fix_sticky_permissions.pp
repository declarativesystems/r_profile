# @summary Scan the system for directories that should have the sticky bit set
#
# Perform a system-wide find across local filesystems for world-writable
# directories and make sure that they all have the sticky bit set so that only
# the owning UID can delete them
#
# WARNING! This class will perform a system-wide find every puppet run!  On a
# modest VM with a 10gb filesystem, this takes approximately 30 seconds, however
# it may much longer if you are running on a system with lots of local disk
# available
class r_profile::linux::fix_sticky_permissions {

  # basic find command used to find the sticky files.  DF is used to make sure
  # we aren't descending remote filesystems
  $find_cmd = "df --local -P | awk {'if (NR!=1) print \$6'} | xargs -I '{}' \
find '{}' -xdev  \\( -type d -a -perm -0002 -a ! -perm -1000 \\) "

  # detect whether the find command matched anything
  $test_cmd = "test \$(${find_cmd} | wc -l) -gt 0"

  # re-run the find command and perform the permission fix
  $fix_cmd = "${find_cmd} | xargs chmod a+t"

  exec { "find_world_writable_and_make_sticky":
    command => $fix_cmd,
    onlyif  => $test_cmd,
    path    => ['/usr/bin', '/bin']
  }

}
