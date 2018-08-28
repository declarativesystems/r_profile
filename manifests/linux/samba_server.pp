# @summary WIP easy samba support
class r_profile::linux::samba_server {

  package { ["samba", "samba-common-bin"]:
    ensure => present,
  }

  file { "/shared":
    ensure => directory,
    owner  => "root",
    group  => "root",
    mode   => "1777",
  }

  service { "samba":
    ensure => running,
    enable => true,
  }
  # sudo smbpasswd -a pi
  #
  # [share]
  # Comment = Pi shared folder
  # Path = /share
  # Browseable = yes
  # Writeable = Yes
  # only guest = no
  # create mask = 0777
  # directory mask = 0777
  # Public = yes
  # Guest ok = yes
}