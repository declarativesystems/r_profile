# R_profile::Windows::Chocolatey
#
# Setup chocolatey package manager on Windows
#
# @see https://forge.puppet.com/puppetlabs/chocolatey
# @see https://forge.puppet.com/puppet/windows_env
#
# @example Basic usage
#   include r_profile::windows::chocolatey
#
# @example Chocolatey settings
#   r_profile::windows::chocolatey:
#     settings:
#       chocolatey_download_url: 'https://internalurl/to/chocolatey.nupkg'
#       use_7zip: false
#       choco_install_timeout_seconds: 2700
#
# @param chocolatey_path Add this directory to the `PATH` variable for easy access to the `choco` command
# @param settings Hash of settings to pass to main chocolatey installer module
class r_profile::windows::chocolatey(
    String            $chocolatey_path  = "c:/ProgramData/chocolatey",
    Hash[String,Any]  $settings = {},
) {

  if $chocolatey_path {
    $chocolatey_path_ensure = present
  } else {
    $chocolatey_path_ensure = absent
  }


  # puppet binaries in path
  windows_env { 'chocolatey_path':
    ensure    => $chocolatey_path_ensure,
    value     => $chocolatey_path,
    mergemode => insert,
    variable  => "Path",
    notify    => Reboot["puppet_reboot"],
  }

  class {'chocolatey':
    * => $settings,
  }
}
