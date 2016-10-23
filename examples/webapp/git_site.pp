class { 'r_profile::webapp::git_site':
  sites  => {
    '/var/www/' => {
      source => 'https://github.com/AppStateESS/phpwebsite'
    }
  }
}
