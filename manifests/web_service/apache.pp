# R_profile::Web_service::Apache
#
# Install and configure Apache webserver
#
# @param website_hash Hash of websites to create in a suitable for for create_resources
#   and the apache::vhost resource
# @param open_firewall True to alter IP tables to allow connection to apache
# @param lb Export a resorce suitable for use with a load balancer
# @param disable_php True to disable support for PHP otherwise it will be installed
# @param nagios_monitored True to export a resource to nagios for monitoring
# @param ip IP address or array of IP addresses to listen on.  Default is to listen
#   on all interfaces
class r_profile::web_service::apache(
    $website_hash       = hiera('r_profile::web_service::apache::website_hash',undef),
    $open_firewall      = hiera('r_profile::web_service::apache::open_firewall', false),
    $lb                 = hiera('r_profile::web_service::apache::lb',true),
    $disable_php        = hiera('r_profile::web_service::apache::disable_php', false),
    $disable_mysql      = hiera('r_profile::web_service::apache::disable_mysql', false),
    $nagios_monitored   = hiera('r_profile::web_service::apache::nagios_monitored', true),
    $ip                 = hiera('r_profile::web_service::apache::ip', undef),
) {

  # port is always 80, you would have to changed listeners, etc to support
  # different/multiple ports
  $port = 80

  class { 'apache':
    default_vhost => false,
  }

  if ! $disable_php {
    include ::apache::mod::php

    class { 'mysql::bindings':
      php_enable => true,
    }
  }

  include ::apache::mod::ssl

  # firewall
  if $open_firewall and !defined(Firewall["100 ${::fqdn} HTTP ${port}"]) {
    firewall { "100 ${::fqdn} HTTP ${port}":
      dport  => $port,
      proto  => 'tcp',
      action => 'accept',
    }
  }

  # load balancer
  # setup the FACT that will tell us what IP address to use (run n)
  if is_string($lb) {
    $lb_address = $lb
  } else {
    if dig($facts, 'pe_server_version') {

      # attempt to lookup which nodes are classified as Haproxies
      # and use first.  Only do this if being run in agent-master mode
      $lb_addresses = query_nodes('Class[R_profile::Monitor::Haproxy]')

      if is_array($lb_addresses) {
        $lb_address = $lb_addresses[0]
      } else {
        $lb_address = false
      }
    } else {
      $lb_address = false
    }
  }
  if $lb_address and is_string($lb) {
    $source_ip = $source_ipaddress[$lb_address]
  } else {
    $source_ip = undef
  }

  if $lb {
    # export the IP address (run n+1)
    @@haproxy::balancermember { $fqdn:
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

  # setup the default vhost here.  we always want one of these.  The main
  # apache module sets one of these up but doesn't let us set the
  # allow_overrides option (.htaccess) that basically every REST framework
  # needs these days...
  # Note we have to use a different title to avoid a name clash with the
  # module
  $default_vhost_docroot = '/var/www/html'
  apache::vhost { 'default-site':
    ensure      => present,
    docroot     => $default_vhost_docroot,
    priority    => '15',
    ip          => $ip,
    port        => $port,
    directories => [
      {
        path           => $default_vhost_docroot,
        allow_override => ['All'],
      },
    ],
  }

  file { '/var/www/html':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  if $website_hash {
    $website_hash.each |String $site_name, Hash $website| {

      $_docroot = "/var/www/${website['docroot']}"

      apache::vhost { $site_name:
        docroot        => $_docroot,
        manage_docroot => $website['manage_docroot'],
        port           => $port,
        priority       => $website['priority'],
        directories    => [
          {
            path           => $_docroot,
            allow_override => ['All'],
          },
        ],
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
