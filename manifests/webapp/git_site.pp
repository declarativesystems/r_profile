# @summary Deploy web site(s) from git
#
# @example Downloading site from git
#   r_profile::webapp::git_site:
#     /var/www/phpquote:
#       source: https://github.com/GeoffWilliams/phpquote
#       revision: master
#       notify: Service['httpd']
#
# @param sites Hash of checkout sources and destinations (see examples)
class r_profile::webapp::git_site(
    Hash[String, Hash[String, Any]] $sites = {},
) {

  $sites.keys.each | $site | {
    vcsrepo { $site:
      ensure   => 'latest',
      provider => 'git',
      source   => $sites[$site]['source'],
      revision => pick($sites[$site]['revision'], 'master'),
      owner    => $sites[$site]['owner'],
      group    => $sites[$site]['group'],
      notify   => $sites[$site]['notify'],
    }
  }
}
