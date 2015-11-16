# Setup a nice version of vim
class r_profile::vim {
  class { 'vim': }

  # install extra bells and whistles for debian
  if $::osfamily == debian {
    package { ["vim-syntax-docker", "vim-syntax-go", "vim-puppet"]: }
  }
}
