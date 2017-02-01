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
    $template     = hiera("r_profile::motd::template", "${module_name}/motd.erb"),
    $content      = hiera("r_profile::motd::content", undef),
    $dynamic_motd = hiera("r_profile::motd::content",true),
) {

  class { "::motd":
    template     => $template,
    content      => $content,
    dynamic_motd => $dynamic_motd,
  }
}
