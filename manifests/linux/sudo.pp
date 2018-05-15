# R_profile::Linux::Sudo
#
# Configure sudo for linux. If the fact `vagrant` exists, then a rule will be added to prevent locking out the `vagrant`
# user.
#
# @example creating the vagrant fact
#   mkdir -p  /etc/puppetlabs/facter/facts.d
#   echo vagrant=true > /etc/puppetlabs/facter/facts.d/vagrant.txt
class r_profile::linux::sudo {
  class { 'sudo': }

  group { ["sudo", "admins"]:
    ensure => present,
  }

  if dig($facts, 'vagrant') {
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
