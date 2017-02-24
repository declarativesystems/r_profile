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
  if $content {
    $_content = $content
  } else {
    $_content = template($template)
  }

  if $kernel == "AIX" {
    if $_content {
      file { "/etc/motd":
        ensure  => file,
        owner   => "bin",
        group   => "bin",
        mode    => "0644",
        content => $_content,
      }
    }
  } else {
    class { "::motd":
      content           => $content,
      issue_content     => $issue_content,
      issue_net_content => $issue_net_content,
    }

    File <| title == '/etc/motd' or title == "/etc/issue" or title == "/etc/issue.net" |> {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

  }

}
