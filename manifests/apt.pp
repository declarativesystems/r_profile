class r_profile::apt(
    $include_src = true,
) {
  if $os["family"] == "Debian" {
    class { "apt":
      purge =>  { 
        "sources.list" => true,
      },
    }

    # only for ubuntu with lsb-release package installed...
    if $lsbdistcodename {
      case $operatingsystem {
        "Ubuntu": {
          $releases          = [
            $lsbdistcodename,
            "${::lsbdistcodename}-updates",
            "${::lsbdistcodename}-security",
          ]
          $repos             = "main restricted universe multiverse"
          $security_repos    = $repos
          $default_location  = "http://archive.ubuntu.com/"
          $security_location = "http://security.ubuntu.com/ubuntu/"
          $security_release  = "${::lsbdistcodename}-security"
        }
        "Debian": {
          $releases          = [
            $lsdbdistcodename,
            "${::lsbdistcodename}-updates",
            "${::lsbdistcodename}-backports",
          ]
          $repos             = "main" # removed non-free
          $security_repos    = "main"
          $default_location  = "http://ftp.debian.org/debian/"
          $security_location = "http://security.debian.org/"
          $security_release  = "${::lsbdistcodename}/updates"
        }
      }

      $os = downcase($operatingsystem)
      $location = hiera(
        "r_profile::apt::${os}::location", 
        $default_location
      )

      # regular updates for each release
      $releases.each | $release | {
        apt::source { "apt_archive_${::lsbdistcodename}-${release}":
          location    => $location,
          release     => $release,
          repos       => $repos,
          include_src => $include_src,
        }
      }

      # security updates - always from main servers
      apt::source { "apt_security":
        location    => $security_location,
        release     => $security_release,
        repos       => $security_repos,
        include_src => $include_src,
      }
    }
  }
}

