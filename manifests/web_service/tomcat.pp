class r_profile::web_service::tomcat(
    $source_url       = 'http://apache.mirror.amaze.com.au/tomcat/tomcat-8/v8.5.9/bin/apache-tomcat-8.5.9.tar.gz',
    $catalina_home    = '/opt/tomcat',
    $service          = 'tomcat',
    $user             = 'tomcat',
    $group            = 'tomcat',
    $port             = 8080,
    $lb               = true,
    $nagios_monitored = true,
    $enable_firewall  = true,
){

  include java

  class { 'tomcat':
    catalina_home => $catalina_home,
    user          => $user,
    group         => $group,
  }

  tomcat::install { $catalina_home:
    source_url => $source_url,
  }

  tomcat::service { $service:
    require => Tomcat::Install[$catalina_home]
  }

  if $lb {

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

    # export the IP address (run n+1)
    @@haproxy::balancermember { "${service_name}-${::fqdn}":
      listening_service => 'tomcat',
      server_names      => $::fqdn,
      ipaddresses       => $source_ip,
      ports             => $port,
      options           => 'check',
    }

    # runs will be collected on the loadbalancer next time it runs puppet
  }

  if $nagios_monitored {
    nagios::nagios_service_http { 'tomcat':
      port => $port,
      url  => '/',
    }
  }

  if $enable_firewall and !defined(Firewall["100 ${::fqdn} HTTP ${port}"]) {
    firewall { "100 ${::fqdn} HTTP ${port}":
      dport   => $port,
      proto   => 'tcp',
      action  => 'accept',
    }
  }
}
