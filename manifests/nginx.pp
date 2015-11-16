class r_profile::nginx {
  class { "::nginx": }

  #  nginx::resource::upstream { 'lsdserver':
  #    members => [
  #      'localhost:3000',
  #    ],
  #  }
  #
  #  nginx::resource::vhost { 'lsdserver.lan.asio':
  #    proxy => 'http://lsdserver',
  #  }
}
