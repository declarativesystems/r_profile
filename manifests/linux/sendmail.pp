# R_profile::Linux::Sendmail
#
# Configure (currently disable) the sendmail daemon.
# * Service configuable (default to stopped/disabled)
# * Set daemon in /etc/sysconfig/sendmail
# * Set queue in /etc/sysconfig/sendmail
#
# @see https://forge.puppet.com/puppetlabs/stdlib
#
# @example disable sendmail
#   include r_profile::linux::sendmail
#
# @param ensure `stopped` to shutdown sendmail if running, otherwise `running` to start
# @param enable `false` to prevent sendmail from starting on boot otherwise false
# @param daemon `no` to prevent sendmail from daemonising otherwise `yes`
# @param queue Interval at which to process the sendmail queue (`-q` parameter to `sendmail`)
class r_profile::linux::sendmail(
    String            $ensure  = "stopped",
    Boolean           $enable  = false,
    Enum["yes","no"]  $daemon  = "no",
    String            $queue   = "1h",
    String            $service = "sendmail",
) {
  $config_file = "/etc/sysconfig/sendmail"

  service { $service:
    ensure => $ensure,
    enable => $enable,
  }

  file { $config_file:
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  file_line { "${config_file} DAEMON":
    ensure => present,
    path   => $config_file,
    line   => "DAEMON=${daemon}",
    match  => "^DAEMON=",
    notify => Service[$service],
  }

  file_line { "${config_file} QUEUE":
    ensure => present,
    path   => $config_file,
    line   => "QUEUE=${queue}",
    match  => "^QUEUE=",
    notify => Service[$service],
  }

}