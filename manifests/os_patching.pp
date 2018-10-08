# @summary Enable OS patching via Puppet Tasks for Windows and Linux
#
# @see https://forge.puppet.com/albatrossflavour/os_patching
#
# @example Basic usage
#   include profile::os_patching
#
# @param enable `true` to prepare system to run os_patching _task_, otherwise
#   `false` to do nothing. Note that settings `false` does not remove the changes
#   this module would have made to an existing system
# @param settings Hash of settings to send through to `os_patching` module (see
#   example)
class profile::os_patching(
    Boolean           $enable   = true,
    Hash[String,Any]  $settings = {},
) {
  if $enabled {
    class { "os_patching":
      * => $settings,
    }
  }
}