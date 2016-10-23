# Deploy web site(s) from git
#
# Params
# ======
# `site`
# Hash of checkout sources and destinations:
# target_directory => {
#   source    => 'url'   # git checkout url
#   revision  => 'ref'   # branch/tag (optional)
#   notify    => Res,    # Puppet resource to notify
#   owner     => 'user'  # local user to own downloaded files
#   group     => 'group' # local group to own downloaded files
# }
class r_profile::webapp::git_site(
    $sites = hiera('r_profile::webapp::git_site::sites', {}),
) {
  
  $sites.keys.each | $site | {
    vcsrepo { $site:
      ensure    => 'latest',
      provider  => 'git',
      source    => $sites[$site]['source'],
      revision  => $sites[$site]['revision'],
      owner     => $sites[$site]['owner'],
      group     => $sites[$site]['group'],
      notify    => $sites[$site]['notify'],
    }
  }
}
