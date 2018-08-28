# @summary Setup `rsyslog` client
#
# Features:
#   * Install Package
#   * General settings
#   * Managed logfiles
#
# @see https://forge.puppet.com/geoffwilliams/rsyslog_client
#
# @example Setup syslog client with settings from hiera
#   include r_profile::linux::rsyslog
#
# @example Hiera data for general rsyslog settings
#   r_profile::linux::rsyslog_client::settings:
#     - '$FileOwner': 'root'
#     - '$FileGroup': 'root'
#     - '$FileCreateMode': '0600'
#     - '$DirOwner': 'root'
#     - '$DirGroup': 'root'
#     - '$DirCreateMode': '0750'
#
# @example Hiera data for rsyslog entries
#   r_profile::linux::rsyslog_client::entries:
#     'daemon.*': /var/log/daemon.log
#     'syslog.*': /var/log/syslog
#
# @param settings Settings to insert into the `rsyslog.conf` file. Existing definitions will be
#   replaced in-place. If a setting is added that doesn't already exist, it will be inserted
#   into the file _from_ line `setting_insertion_line`. Settings will be processed in array
#   order (see examples)
# @param entries Hash of logging entries to create (see examples)
# @param service_ensure How to ensure the rsyslog service
# @param service_enable `true` to start rsyslog on boot otherwise false
class r_profile::linux::rsyslog_client(
  Array[Hash[String, Any]]  $settings       = [],
  Hash[String,String]       $entries        = {},
  Enum['running','stopped'] $service_ensure = "running",
  Boolean                   $service_enable = true,
) {

  class { 'rsyslog_client':
    settings       => $settings,
    entries        => $entries,
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  }

}