# @summary Basic 'baselevel' class for Windows
class r_profile::windows::base {
  include r_profile::windows::chocolatey
  include r_profile::windows::powershell
  include r_profile::windows::notepad_plus_plus
  include r_profile::windows::puppet_agent
}
