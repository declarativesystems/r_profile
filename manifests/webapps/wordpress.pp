class r_profile::webapps::wordpress(
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

  include r_profile::web_services::apache
  apache::vhost { $::fqdn:
    port     => '80',
    priority => '00',
    docroot  => '/opt/wordpress',
  }
  
  
  include ::wordpress

}
