# R_profile::Motd
#
# Simple MOTD support for POSIX and Windows.
#
# Requires: puppetlabs-mysql
#
# [params]
# *template*
#   template FILE to use for the MOTD
# *inline_template*
#   string to be processed as an inline template for the MOTD
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
      template          => $template,
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
