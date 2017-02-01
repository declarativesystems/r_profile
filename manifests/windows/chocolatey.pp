# R_profile::Windows::Chocolatey
#
# Setup chocolatey package manager on Windows
class r_profile::windows::chocolatey(
    $install_location = hiera("r_profile::windows::chocolatey::install_location", undef),
    $download_url     = hiera("r_profile::windows::chocolatey::download_url", undef),
    $use_7zip         = hiera("r_profile::windows::chocolatey::use_7zip", undef),
    $timeout          = hiera("r_profile::windows::chocolatey::timeout", undef),
    $chocolatey_path  = hiera("r_profile::windows::chocolatey::path", "c:/ProgramData/chocolatey")
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
    chocolatey_download_url       => $download_url,
    choco_install_location        => $install_location,
    use_7zip                      => $use_7zip,
    choco_install_timeout_seconds => $timeout,
  }
}
