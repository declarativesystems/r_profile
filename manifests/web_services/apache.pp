class r_profile::web_services::apache(
    $website_hash       = hiera('r_profile::web_services::apache::website_hash',undef),
    $enable_firewall    = hiera('r_profile::web_services::apache::enable_firewall', true),
    $lb                 = hiera('r_profile::web_services::apache::lb',true),
    $disable_php        = hiera('r_profile::web_services::apache::disable_php', false),
    $nagios_monitored   = hiera('r_profile::web_services::apache::nagios_monitored', true),
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

  if $website_hash {
    $website_hash.each |String $site_name, Hash $website| {

      if $_bypass or ($search_results != 0) {
        $_docroot = "/var/www/${website['docroot']}"

        apache::vhost { $site_name:
          docroot        => $_docroot,
          manage_docroot => $website['manage_docroot'],
          port           => $port,
          priority       => $website['priority'],
        }

        # Exported load balancer configuration if required
        if $lb_address and is_string($lb) {
          source_ipaddress{ $lb_address: }
          $source_ip = $source_ipaddress[$lb_address]
        } else {
          $source_ip = undef
        }

        # load balancer
        if $lb {
          # export the IP address (run n+1)
          @@haproxy::balancermember { "${site_name}-${::fqdn}":
            listening_service => 'apache',
            server_names      => $site_name,
            ipaddresses       => $source_ip,
            ports             => $port,
            options           => 'check',
          }
        }

        # nagios
        if $nagios_monitored {
          nagios::nagios_service_http { $site_name:
            port => $port,
          }
        }
      }
    }
  }
}

