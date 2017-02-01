# R_profile::Windows::Notepad_plus_plus
#
# Install notepad++ on windows
class r_profile::windows::notepad_plus_plus {
  package { "notepadplusplus":
    ensure => present,
  }
}
