class r_profile::chocolatey(
    $install_location = hiera("r_profile::chocolatey::install_location", undef),
    $download_url = hiera("r_profile::chocolatey::download_url", undef),
    $use_7zip = hiera("r_profile::chocolatey::use_7zip", undef),
    $timeout = hiera("r_profile::chocolatey::timeout", undef), 
) {
  class {'chocolatey':
    chocolatey_download_url       => $download_url,
    choco_install_location        => $install_location,
    use_7zip                      => $use_7zip,
    choco_install_timeout_seconds => $timeout,
   }
}
