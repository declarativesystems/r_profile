# R_profile::Linux::Ssh
#
# SSH support on linux using declarativesystems-ssh
class r_profile::linux::ssh() {
  class { "ssh":
    permit_root_login => "no",
    banner            => "/etc/ssh/ssh-banner",
    extra_config      => {
      "GSSAPICleanupCredentials" => {
        "value" =>"yes",
      },
      # "Motd"
    }
  }
}