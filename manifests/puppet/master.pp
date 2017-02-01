# R_profile::Puppet::Master
#
# Puppet Master general settings
#
# @param $data_binding_terminus enable/disable automatic hiera lookups
# @param $open_firewall open ports in IPTables?
# @param $nagios_monitored create nagios monitoring resources?
class r_profile::puppet::master (
    Enum['none', 'hiera'] $data_binding_terminus =
      hiera("r_profile::puppet::master::data_binding_terminus", $r_profile::puppet::params::data_binding_terminus),
    Boolean $open_firewall    = hiera("r_profile::puppet::master::open_firewall", false),
    Boolean $nagios_monitored = hiera("r_profile::puppet::master::nagios_monitored", false),
) inherits r_profile::puppet::params {

  $puppetconf = $r_profile::puppet::params::puppetconf

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

  # data binding terminus explicit
  ini_setting { "puppet.conf data_binding_terminus":
    ensure  => present,
    setting => "data_binding_terminus",
    value   => $data_binding_terminus,
    section => "master",
    path    => $puppetconf,
    notify  => Service["pe-puppetserver"],
  }

  if $open_firewall {
    [8140, 61613, 443, 8142].each | $port | {
      if !defined(Firewall["100 ${::fqdn} HTTP ${port}"]) {
        firewall { "100 ${::fqdn} HTTP ${port}":
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

    nagios::nagios_service_tcp { 'PE MCollective':
      port => 61613,
    }

    nagios::nagios_service_tcp { 'PE PCP/PXP':
      port => 8142,
    }
  }

}
