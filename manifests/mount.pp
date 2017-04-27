# R_profiles::mount
#
# Configure filesystem mounts
#
# @param mount hash of mounts to mount
# @param default hash of default mount options
class r_profile::mount($mount={}, $default={}) {
  ensure_resources("mount", $mount, $default)
}
