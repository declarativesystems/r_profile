# R_profile::Linux::Umask
#
# Set the umask for each of the requested files
#
# @example Activate the umask profile
#   include r_profile::linux::umask
#
# @example Hiera data to set a restrictive umask
#   r_profile::linux::umask::default_umask: '0077'
#
# @example Hiera data to set umask in several files with one exception
#   r_profile::linux::umask::files:
#     /etc/profile.d/umask:
#     /root/.bashrc:
#     /var/lib/myapp/.bashrc: '0007'
class r_profile::linux::umask(
    String                          $default_umask = '0022',
    Hash[String, Optional[String]]  $files  = {}
) {

  $files.each |$key, $opts| {
    fm_replace { "${key}:umask":
      ensure            => present,
      data              => "umask ${pick(umask, default_umask)}",
      match             => "^umask",
      insert_if_missing => true,
      insert_at         => 'bottom',
    }
  }
}