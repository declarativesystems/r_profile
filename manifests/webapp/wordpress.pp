# @summary Install wordpress CMS using `hunner-wordpress`
class r_profile::webapp::wordpress() {
  apache::vhost { $facts['fqdn']:
    port     => '80',
    priority => '00',
    docroot  => '/opt/wordpress',
  }

  include ::wordpress
}
