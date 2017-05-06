# R_profile::Motd
#
# Simple MOTD support for POSIX and Windows.  To ensure file permissions are
# explicitly set, I had to use a resource collector against the files that the
# `puppetlabs-motd` module creates.
#
# @param template Process this tempalate and pass the evaluated string to the
#   `puppetlabs-motd` module
# @param content Complete message as to insert into /etc/motd
# @param issue_content Complete message as to insert into /etc/issue
# @param issue_net_content Complete message as to insert into /etc/issue.net
class r_profile::motd(
    $template           = hiera("r_profile::motd::template", "${module_name}/motd.erb"),
    $content            = hiera("r_profile::motd::content", undef),
    $issue_content      = hiera("r_profile::motd::issue_content", undef),
    $issue_net_content  = hiera("r_profile::motd::issue_net_content", undef),
) {

  # content overrides template
  $_content = pick($content, template($template))
  class { "motd":
    content           => $_content,
    issue_content     => $issue_content,
    issue_net_content => $issue_net_content,
  }
}
