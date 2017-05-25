# R_profile::Nodejs
#
# Install NodeJS using the puppet/nodejs module
#
# @param repo_url_suffix Hints at what version of nodejs to install
# @param repo_class Use a specific respository, eg `epel`
class r_profile::nodejs(
    $repo_url_suffix = hiera("r_profile::nodejs::repo_url_suffix", undef),
    $repo_class      = hiera("r_profile::nodejs::repo_class", undef),
) {
  class { 'nodejs':
    repo_url_suffix => $repo_url_suffix,
    repo_class      => $repo_class,
  }
}
