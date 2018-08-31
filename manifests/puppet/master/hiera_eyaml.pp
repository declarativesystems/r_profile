# @summary Configure hiera-eyaml package and/or encryption keys
#
# Configure hiera-eyaml by generating the encryption keys. Current versions of
# Puppet Enterprise ~2018x ship a vendored eyaml gem so installation is not
# needed anymore.
#
# Beware that if you are running Puppet Enterprise and install the
# `puppetlabs-puppetserver_gem` module, you will run into ENTERPRISE-1179. To
# fix this, you must remove `puppetlabs-puppetserver_gem` from your
# `Puppetfile` and re-deploy code.
#
# @see https://tickets.puppetlabs.com/browse/ENTERPRISE-1179
#
# If you must install hiera-eyaml gem for some reason, then you will have to
# install `puppetlabs-puppetserver_gem` module and follow the example below to
# enable gem installation.
#
# If you want more then one keypair per server then you should not use this class.
#
# Files created:
# * `/etc/puppetlabs/puppet/keys/private_key.pkcs7.pem` (private key)
# * `/etc/puppetlabs/puppet/keys/public_key.pkcs7.pem` (public key)
#
# The example below shows how to generate eyaml on the Puppet Master. By sharing
# the server's public key this process can be carried out anywhere and does
# not require root access to the Puppet Master.
#
# @see https://forge.puppet.com/puppetlabs/puppetserver_gem
#
# @example Install the hiera-eyaml gems (not needed for modern Puppet Enterprise)
#   r_profile::puppet::master::hiera_eyaml::gem_install: true
#
# @example Prevent key creation
#   r_profile::puppet::master::hiera_eyaml::create_keys: false
#
# @example encrypting data on the Puppet Master
#   cd /etc/puppetlabs/puppet
#   /opt/puppetlabs/puppet/lib/ruby/vendor_gems/bin/eyaml encrypt --password
#
# @param create_keys True to create a system-wide eyaml keypair
# @param gem_install True to attempt to install and configure hiera-eyaml rubygem
class r_profile::puppet::master::hiera_eyaml(
    Boolean $gem_install  = false,
    Boolean $create_keys  = true,
) {

  if $gem_install {
    # If we're on old PE/POS then we need to install ourselves with a composite namevar:
    # http://www.craigdunn.org/2016/07/composite-namevars-in-puppet/
    package { "vendored ruby eyaml":
      ensure   => present,
      name     => "hiera-eyaml",
      provider => puppet_gem,
      before   => Exec['createkeys'],
    }

    package { "vendored jruby eyaml":
      ensure   => present,
      name     => "hiera-eyaml",
      provider => puppetserver_gem,
      notify   => Service['pe-puppetserver'],
      before   => Exec['createkeys'],
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
      require => File[$keysdir]
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
