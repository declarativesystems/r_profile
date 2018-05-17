# R_profile::Puppet::Master::Hiera_eyaml
#
# Configure hiera-eyaml by generating the encryption keys. Current versions of
# Puppet Enterprise ~2018x ship a vendored eyaml gem so installation is not
# normally needed anymore.
#
# If you want more then one keypair per server, you should set create_keys false
# and make your own arrangements
#
# @param gem_install True to attempt to install and configure hiera-eyaml rubygem
# @param create_keys, True to create a system-wide eyaml keypair
class r_profile::puppet::master::hiera_eyaml(
    $gem_install  = hiera('r_profile::puppet::master::hiera::gem_install', true),
    $create_keys  = hiera('r_profile::puppet::master::hiera::create_keys', true),
) inherits r_profile::puppet::params {

  if $gem_install {
    # Hiera module will only install eyaml if the manage_package attribute is set,
    # however, setting this also installs the hiera package itself, eg completly
    # breaks puppet enterprise ;-) best thing to do here is install eyaml ourselves
    # and then use the hiera module to finish setting up the hierarchy and eyaml
    # keys.  Note that we have to do this twice - once for vendored ruby and once
    # for vendored jruby.  This isn't need for installations created with
    # puppetizer since it does all this for you...

    # we need a composite namevar to allow this to succeed:
    # http://www.craigdunn.org/2016/07/composite-namevars-in-puppet/
    package { "vendored ruby eyaml":
      ensure   => present,
      name     => "hiera-eyaml",
      provider => puppet_gem,
    }

    package { "vendored jruby eyaml":
      ensure   => present,
      name     => "hiera-eyaml",
      provider => puppetserver_gem,
      notify   => Service['pe-puppetserver'],
    }
  }

  if $create_keys {
    $keysdir = "${::settings::confdir}/keys"

    file { $keysdir:
      ensure => directory,
      owner  => 'pe-puppet',
      group  => 'pe-puppet',
      mode   => '0600',
    }

    exec { 'createkeys':
      user    => 'pe-puppet',
      cwd     => $::settings::confdir,
      command => 'eyaml createkeys',
      path    => ['/opt/puppetlabs/puppet/bin', '/usr/bin', '/usr/local/bin', '/opt/puppetlabs/puppet/lib/ruby/vendor_gems/bin'],
      creates => "${keysdir}/private_key.pkcs7.pem",
      require => [File[$keysdir],  Package["vendored ruby eyaml"], Package["vendored jruby eyaml"]],
    }

    file { "${keysdir}/private_key.pkcs7.pem":
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0600',
      require => Exec['createkeys'],
    }

    file { "${keysdir}/public_key.pkcs7.pem":
      ensure  => file,
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0644',
      require => Exec['createkeys'],
    }
  }
}
