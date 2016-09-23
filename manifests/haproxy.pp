class r_profile::haproxy(
  $listeners        = hiera('r_profile::haproxy::listeners',undef),
  $enable_firewall  = hiera('r_profile::haproxy::enable_firewall', false),
  $frontends        = hiera('r_profile::haproxy::frontends',undef),
  $backends         = hiera('r_profile::haproxy::backends',undef),
  $stats            = hiera('r_profile::haproxy::stats', true),
) {

  #Firewall {
  #  before  => Class['profile::fw::post'],
  #  require => Class['profile::fw::pre'],
  #}

  class { "haproxy":
    stats => $stats,
  }

  if $listeners {
    $listeners.each |String $listener,Hash $listener_values| {
      haproxy::listen { $listener:
        * => $listener_values,
      }

      if $enable_firewall {
        firewall { "100 ${listener}":
          dport  => [$listener_values['ports']],
          proto  => 'tcp',
          action => 'accept',
        }
      }
    }
  }

  if $frontends {
    $frontends.each |String $frontend, Hash $frontend_values| {
      haproxy::frontend { $frontend:
        * => $frontend_values,
      }

      if $enable_firewall {
        firewall { "100 ${frontend}":
          dport  => [$frontend_values['ports']],
          proto  => 'tcp',
          action => 'accept',
        }
      }
    }
  }

  if $backends {
    $backends.each |String $backend, Hash $backend_values| {
      haproxy::backend { $backend:
        * => $backend_values,
      }
    }
  }
}

