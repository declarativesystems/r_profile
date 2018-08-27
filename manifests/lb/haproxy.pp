# R_profile::Lb::Haproxy
#
# A haproxy based load-balancer
#
# https://tickets.puppetlabs.com/browse/MODULES-3932
#
# @param listeners Hash of listeners to create
# @param frontends Hash of frontends to create
# @param backends Hash of backends to create
# @param admin_stats `true` to enable the built-in stats web page
# @param stats_port TCP Port to run stats on
# @param stats_username Username for stats website
# @param stats_password Password for stats website
class r_profile::lb::haproxy(
  Hash[String, Hash[String, Any]] $listeners      = {},
  Hash[String, Hash[String, Any]] $frontends      = {},
  Hash[String, Hash[String, Any]] $backends       = {},
  Boolean                         $admin_stats    = false,
  Array[Integer]                  $stats_port     = [9090],
  String                          $stats_username = "puppet",
  String                          $stats_password = "puppet",
) {

  include haproxy
  if $admin_stats {
    haproxy::listen { 'stats':
      ipaddress => '0.0.0.0',
      ports     => $stats_port,
      options   => {
        'mode'  => 'http',
        'stats' => ['uri /', "auth ${stats_username}:${stats_password}"],
        },
    }

  }

  $listeners.each |String $listener,Hash $listener_values| {
    haproxy::listen { $listener:
      * => $listener_values,
    }
  }

  $frontends.each |String $frontend, Hash $frontend_values| {
    haproxy::frontend { $frontend:
      * => $frontend_values,
    }
  }

  $backends.each |String $backend, Hash $backend_values| {
    haproxy::backend { $backend:
      * => $backend_values,
    }
  }
}
