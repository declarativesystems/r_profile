# @summary Setup a nice version of vim
class r_profile::linux::vim {
  class { 'vim': }

  # install extra bells and whistles for debian
  if $::osfamily == debian {
    package { ["vim-syntax-docker", "vim-puppet"]: }

    # broken because of https://bugs.launchpad.net/ubuntu/+source/vim-addon-manager/+bug/1513446
    #exec { "vim_puppet_plugin_install":
    #  command => "vim-addons -w install puppet",
    #  path    => ["/bin", "/usr/bin"],
    #  unless  => "vim-addons | grep -e 'puppet.*installed'",
    #}

    file { [  "/var/lib/vim/addons/ftdetect",
              "/var/lib/vim/addons/ftplugin",
              "/var/lib/vim/addons/indent",
              "/var/lib/vim/addons/syntax", ]:
      ensure => directory,
      owner  => "root",
      group  => "root",
      mode   => "0755",
    }

    file { "/var/lib/vim/addons/ftdetect/puppet.vim":
      ensure => link,
      target => "/usr/share/vim/addons/ftdetect/puppet.vim",
    }

    file { "/var/lib/vim/addons/ftplugin/puppet.vim":
      ensure => link,
      target => "/usr/share/vim/addons/ftplugin/puppet.vim",
    }

    file { "/var/lib/vim/addons/indent/puppet.vim":
      ensure => link,
      target => "/usr/share/vim/addons/indent/puppet.vim",
    }

    file { "/var/lib/vim/addons/syntax/puppet.vim":
      ensure => link,
      target => "/usr/share/vim/addons/syntax/puppet.vim",
    }

    file { "/etc/vim/vimrc.local":
      ensure => file,
      source => "puppet:///modules/${module_name}/vimrc.local",
    }

  }
}
