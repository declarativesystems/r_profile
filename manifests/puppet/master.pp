# R_profile::Puppet::Master
#
# Enable restarting the `pe-puppetserver` service if its systemd environment is changed
#
# @param sysconf_puppetserver Path to sysconfig settings for pe-puppetserver
class r_profile::puppet::master(
    String $sysconf_puppetserver = "${facts['sysconf_dir']}/pe-puppetserver",
) {
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
