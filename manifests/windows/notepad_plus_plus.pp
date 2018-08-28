# @summary Install notepad++ on windows
class r_profile::windows::notepad_plus_plus {
  package { "notepadplusplus":
    ensure => present,
  }
}
