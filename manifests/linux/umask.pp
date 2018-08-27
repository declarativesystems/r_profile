# R_profile::Linux::Umask
#
# Set the umask for each of the requested files. The files must already exist in order to add a line
# to them. r_profile::file can be used to do this if required.
#
# @see https://forge.puppet.com/geoffwilliams/filemagic/readme
#
# @example Activate the umask profile
#   include r_profile::linux::umask
#
# @example Hiera data to set a restrictive umask
#   r_profile::linux::umask::default_umask: '0077'
#
# @example Hiera data to set umask in several files with one exception
#   r_profile::linux::umask::files:
#     /etc/profile.d/umask.sh:
#     /root/.bashrc:
#     /var/lib/myapp/.bashrc: '0007'
#
# @param default_umask Default umask value
# @param files Hash of files to set the umask in. `default_umask` will be used unless a
#   file sets a value explicitly (see examples)
class r_profile::linux::umask(
    String                          $default_umask = '0022',
    Hash[String, Optional[String]]  $files  = {}
) {

  $files.each |$key, $opts| {
    fm_replace { "${key}:umask":
      ensure            => present,
      path              => $key,
      data              => "umask ${pick($opts, $default_umask)}",
      match             => "^umask",
      insert_if_missing => true,
      insert_at         => 'bottom',
    }
  }
}