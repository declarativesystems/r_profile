class r_profile::sudo {
  class { 'sudo': }

  group { ["sudo", "admins"]:
    ensure => present,
  }
  
  if $vagrant {
    sudo::conf { "vagrant":
      priority => 10,
      content  => "%vagrant ALL=(ALL) NOPASSWD: ALL",
    }
  }

  sudo::conf { 'admins':
    priority => 20,
    content  => "%admins ALL=(ALL) NOPASSWD: ALL",
  }

  sudo::conf { 'sudo':
    priority => 30,
    content  => "%sudo ALL=(ALL:ALL) ALL",
  }

}
