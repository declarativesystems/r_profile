class r_profile::web_service::apache(
    $website_hash       = hiera('r_profile::web_service::apache::website_hash',undef),
    $enable_firewall    = hiera('r_profile::web_service::apache::enable_firewall', true),
    $lb                 = hiera('r_profile::web_service::apache::lb',true),
    $disable_php        = hiera('r_profile::web_service::apache::disable_php', false),
    $nagios_monitored   = hiera('r_profile::web_service::apache::nagios_monitored', true),
) {

  # port is always 80, you would have to changed listeners, etc to support 
  # different/multiple ports
  $port = 80

  include ::apache
  if ! $disable_php {
    include ::apache::mod::php
  }  

  include ::apache::mod::ssl

  # firewall
  if $enable_firewall and !defined(Firewall["100 ${::fqdn} HTTP ${port}"]) {
    firewall { "100 ${::fqdn} HTTP ${port}":
      dport   => $port,
      proto   => 'tcp',
      action  => 'accept',
    }
  }

  # load balancer
  # setup the FACT that will tell us what IP address to use (run n)
  if is_string($lb) {
    $lb_address = $lb
  } else {
    # attempt to lookup which nodes are classified as Haproxies and use first
    $lb_addresses = query_nodes('Class[R_profile::Monitor::Haproxy]')
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

  if $lb {
    # export the IP address (run n+1)
    @@haproxy::balancermember { "${site_name}-${::fqdn}":
      listening_service => 'apache',
      server_names      => $fqdn,
      ipaddresses       => $source_ip,
      ports             => $port,
      options           => 'check',
    }
  }

  # nagios for main host
  if $nagios_monitored {
    nagios::nagios_service_http { $fqdn:
      port => $port,
    }
  }

  if $website_hash {
    $website_hash.each |String $site_name, Hash $website| {

      $_docroot = "/var/www/${website['docroot']}"

      apache::vhost { $site_name:
        docroot        => $_docroot,
        manage_docroot => $website['manage_docroot'],
        port           => $port,
        priority       => $website['priority'],
      }

      # Add to load balancer if enabled and we should use a different listener
      if $lb and $website['lb_listener'] {
        # export the IP address (run n+1)
        @@haproxy::balancermember { "${site_name}-${::fqdn}":
          listening_service => $website['lb_listener'],
          server_names      => $site_name,
          ipaddresses       => $source_ip,
          ports             => $port,
          options           => 'check',
        }
      }

      # nagios for VHOST
      if $nagios_monitored {
        nagios::nagios_service_http { $site_name:
          port => $port,
        }
      }
    }
  }
}

