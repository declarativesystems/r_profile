# simple MOTD support for linux
#
# [params]
# *template*
#   template FILE to use for the MOTD 
# *inline_template*
#   string to be processed as an inline template for the MOTD
class r_profile::motd(
    $template         = hiera("r_profile::motd::template", undef),
    $inline_template  = hiera("r_profile::motd::inline_template", ""),
) {

  class { "::motd": 
    template        => $template,
    inline_template => $inline_template,
  }
}
