class r_profile::wordpress(
    $nagios_monitored = true,
    $enable_firewall  = true,
    $lb               = true,
) {
  class { 'mysql::server':
    root_password => 'puppetlabs',
  }
  class { 'mysql::bindings':
    php_enable => true,
  }

  include apache
  include apache::mod::php
  apache::vhost { $::fqdn:
    port     => '80',
    priority => '00',
    docroot  => '/opt/wordpress',
  }

  include ::wordpress

  if $nagios_monitored {
    nagios::nagios_service_http { 'wordpress':
      port => $port,
      url  => '/',
    }
  }

  if $enable_firewall and !defined(Firewall["100 ${::fqdn} HTTP ${port}"]) {
    firewall { "100 ${::fqdn} HTTP ${port}":
      dport   => 80,
      proto   => 'tcp',
      action  => 'accept',
    }
  }


  if $lb {

    # setup the FACT that will tell us what IP address to use (run n)
    if is_string($lb) {
      $lb_address = $lb
    } else {
      # attempt to lookup which nodes are classified as Haproxies and use first
      $lb_addresses = query_nodes('Class[R_profile::Haproxy]')
      if is_array($lb_addresses) {
        $lb_address = $lb_addresses[0]
      } else {
        $lb_address = false
      }
    }

    if $lb_address and is_string($lb) {
      source_ipaddress{ $lb_address: }
      $source_ip = $source_ipaddress[$lb_address]
    } else {
      $source_ip = undef
    }

    # export the IP address (run n+1)
    @@haproxy::balancermember { "${service_name}-${::fqdn}":
      listening_service => 'wordpress',
      server_names      => $::fqdn,
      ipaddresses       => $source_ip,
      ports             => '80',
      options           => 'check',
    }

    # runs will be collected on the loadbalancer next time it runs puppet
  }
}
