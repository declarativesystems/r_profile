# R_profile::Motd
#
# Simple MOTD support for POSIX and Windows.
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
# @param content Complete message as to insert into /etc/motd
# @param issue_content Complete message as to insert into /etc/issue
# @param issue_net_content Complete message as to insert into /etc/issue.net
# @param identical_content Use value from `content` for all files unless overriden individually
class r_profile::motd(
    Optional[String] $content           = undef,
    Optional[String] $issue_content     = undef,
    Optional[String] $issue_net_content = undef,
    Boolean          $identical_content = true,
) {

  class { "motd":
    content           => $content,
    issue_content     => $issue_content,
    issue_net_content => $issue_net_content,
    identical_content => $identical_content,
  }
}
