# R_profile::Puppet::Master
#
# Puppet Master general settings
#
# @param open_firewall open ports in IPTables?
# @param nagios_monitored create nagios monitoring resources?
# @param agent_ensure `stopped` to ensure the master's puppet agent is stopped,
#   `running` to ensure running
# @param agent_enable true to start the master's puppet agent on boot, false
#   to not start it
class r_profile::puppet::master (
    Boolean $open_firewall    = hiera("r_profile::puppet::master::open_firewall", false),
    Boolean $nagios_monitored = hiera("r_profile::puppet::master::nagios_monitored", false),
    Enum['running', 'stopped'] $agent_ensure =
      hiera("r_profile::puppet::master::agent_ensure", 'running'),
) inherits r_profile::puppet::params {

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

  if $open_firewall {
    [8140, 61613, 443, 8142].each | $port | {
      if !defined(Firewall["100 ${facts['fqdn']} HTTP ${port}"]) {
        firewall { "100 ${facts['fqdn']} HTTP ${port}":
          dport  => $port,
          proto  => 'tcp',
          action => 'accept',
        }
      }
    }
  }

  if $nagios_monitored {
    nagios::nagios_service_tcp { 'PE puppetserver':
      port => 8140,
    }

    nagios::nagios_service_tcp { 'PE console':
      port => 443,
    }

    nagios::nagios_service_tcp { 'PE PCP/PXP':
      port => 8142,
    }
  }

}
