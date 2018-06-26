# R_profile::Motd
#
# Simple MOTD support for POSIX and Windows.
#
# @see https://forge.puppet.com/geoffwilliams/motd/readme
#
# @example Hiera data to set `/etc/motd`, `/etc/issue` and `/etc/issue.net` to the same message
#   r_profile::motd::content: |
#     %{facts.fqdn}
#     ===================================================================
#     This box is managed by Puppet Enterprise and is a cowboy free zone!
#
#   _results in_
#
#   pe-puppet.localdomain
#   ===================================================================
#   This box is managed by Puppet Enterprise and is a cowboy free zone!
#
# @example Hiera data for /etc/motd (message once logged in)
#   r_profile::motd::identical_content: false
#   r_profile::motd::content: |
#     ...
#
# @example Hiera data for /etc/issue (pre-login message)
#   r_profile::motd::identical_content: false
#   r_profile::motd::issue: |
#     ...
#
# @example Hiera data for /etc/issue.net (pre-login message for telnet and other nominated services)
#   r_profile::motd::identical_content: false
#   r_profile::motd::issue.net: |
#     ...
#
# @example Hiera data for blank MOTD (no message)
#   r_profile::motd::content: false
#
# @param content The message to use for login message (or all messages) on all platforms or `false` to write an empty
#   file
# @param issue_content The message  to be used for `/etc/issue` (pre-login message - linux only) or `false` to write an
#   empty file
# @param issue_net_content The message to be used for `/etc/issue.net` (pre-login message for telnet/other nominated
#   services - linux only) or `false` to write an empty file
# @param identical_content `true` to use the main MOTD message from `content` for all messages unless overriden
#   individually by `issue_content` and `issue_net` (linux only)
class r_profile::motd(
    Variant[Boolean, Optional[String]]  $content            = undef,
    Variant[Boolean, Optional[String]]  $issue_content      = undef,
    Variant[Boolean, Optional[String]]  $issue_net_content  = undef,
    Boolean                             $identical_content  = true,
) {

  class { "motd":
    content           => $content,
    issue_content     => $issue_content,
    issue_net_content => $issue_net_content,
    identical_content => $identical_content,
  }
}
