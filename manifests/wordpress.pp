class r_profile::wordpress(
    $nagios_monitored = true,
    $enable_firewall  = true,
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
}
