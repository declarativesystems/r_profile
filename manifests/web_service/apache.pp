# @summary Install and configure Apache webserver
#
# @param website_hash Hash of websites to create in a suitable for for create_resources
#   and the apache::vhost resource
# @param disable_php `true` to disable support for PHP otherwise it will be installed
# @param disable_mysql `true` to disable support for mysql in PHP otherwise enable it
# @param ip IP address or array of IP addresses to listen on.  Default is to listen
#   on all interfaces
class r_profile::web_service::apache(
    Hash              $website_hash  = {},
    Boolean           $disable_php   = false,
    Boolean           $disable_mysql = false,
    Optional[String]  $ip            = undef,
) {

  # port is always 80, you would have to changed listeners, etc to support
  # different/multiple ports
  $port = 80

  class { 'apache':
    default_vhost => false,
  }

  if ! $disable_php {
    include ::apache::mod::php

    if ! $disable_mysql {
      class { 'mysql::bindings':
        php_enable => true,
      }
    }
  }

  include ::apache::mod::ssl

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

  }
}
