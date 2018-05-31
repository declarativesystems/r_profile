# R_profile::Puppet::Master
#
# Enable restarting the `pe-puppetserver` service if its systemd environment is changed
class r_profile::puppet::master inherits r_profile::puppet::params {

  $sysconf_puppetserver   = $r_profile::puppet::params::sysconf_puppetserver

  file { $sysconf_puppetserver:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  # restart master service if any file_lines change its config file
  File_line <| path == $sysconf_puppetserver |> ~>  [
    Exec["systemctl_daemon_reload"],
    Service["pe-puppetserver"],
  ]
}
