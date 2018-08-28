# @summary Configure nagios to monitor something
#
# @param nagios_server Hostname of nagios server
class r_profile::monitor::nagios_monitored(
  Optional[String]  $nagios_server = undef,
) {

  # sometimes we might need to determine the incoming ethernet adaptor to use for
  # checks in multi-honed environments to allow PING or simulate dns
  if $nagios_server {
    $local_ip = $source_ipaddress[$nagios_server]
  } else {
    $local_ip = undef
  }

  class { 'nagios':
    local_ip      => $local_ip,
  }

  @@nagios_host { $facts['fqdn']:
    ensure  => present,
    address => $local_ip,
    use     => "${downcase($facts['kernel'])}-server",
  }

}
