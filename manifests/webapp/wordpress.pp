# R_profile::Webapp::Wordpress
#
# Install wordpress CMS using `hunner-wordpress`
class r_profile::webapp::wordpress(
    $nagios_monitored = true,
) {
  apache::vhost { $::fqdn:
    port     => '80',
    priority => '00',
    docroot  => '/opt/wordpress',
  }

  include ::wordpress
  if $nagios_monitored {
    nagios::nagios_service_http { 'wordpress':
      url => '/wp-admin/install.php',
    }
  }
}
