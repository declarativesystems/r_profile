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
    $dynamic_motd       = hiera("r_profile::motd::dynamic_motd",true),
) {

  if $kernel == "AIX" {
    if $content {
      file { "/etc/motd":
        ensure  => file,
        owner   => "bin",
        group   => "bin",
        mode    => "0644",
        content => $content,
      }
    }
  } else {
    class { "::motd":
      template          => $template,
      content           => $content,
      dynamic_motd      => $dynamic_motd,
      issue_content     => $issue_content,
      issue_net_content => $issue_net_content,
    }

    File <| title == '/etc/motd' or title == "/etc/issue" or title == "/etc/issue.net" |> {
      owner => 'root',
      group => 'root',
      mode  => '0644',
    }

    # if $issue_content {
    #   File["/etc/issue"] {
    #     owner +> "root",
    #     group +> "root",
    #     mode  +> "0644",
    #   }
    # }
    #
    # if $issue_net_content {
    #   File["/etc/issue.net"] {
    #     owner +> "root",
    #     group +> "root",
    #     mode  +> "0644",
    #   }
    # }
    #
  }

}
