class r_profile::nagios_monitored(
  $nagios_server = hiera('r_profile::nagios_monitored::nagios_server', false),
) {

  # sometimes we might need to determine the incoming ethernet adaptor to use for 
  # checks in multi-honed environments to allow PING or simulate dns  
  if $nagios_server {
    source_ipaddress { $nagios_server: }

    # effective on the SECOND puppet run after above resource processed...
    $local_ip = $source_ipaddress[$nagios_server]
  } else {
    $local_ip = undef
  }

  class { 'nagios':
    local_ip      => $local_ip,
    nagios_server => $nagios_server,
  }

  @@nagios_host { $fqdn: 
    ensure  => present,
    address => $local_ip,
    use     => "${downcase($kernel)}-server",
  }

}
