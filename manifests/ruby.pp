# R_profile::Ruby
#
# Install a system-level ruby for customer applications to use.  While its
# possible to use Puppet's vendored ruby for everything, its safter to for
# customer to install their own ruby for internal apps to use since otherwise
# messing with the gems could break puppet in such a way that it is unable to
# run, leaving the system unmanaged
#
# @param version Array of Ruby versions to install (linux).  On windows, only
#   a single version can be installed due to packaging so we will install the
#   first listed version.  On linux, the first listed version will be set as the
#   default
# @param gems Hash of default gems to install in a form suitable for
#   create_resources of the `rbenv::gem` type (not recommened - please use
#   bundler) @see https://forge.puppet.com/jdowning/rbenv#full-example
# @param rbenv_plugins Array of rbenv pluings to install (for building new rubies)
class r_profile::ruby(
    $version        = hiera('r_profile::ruby::version', ['2.4.1', '2.3.4']),
    $gems           = hiera('r_profile::ruby::gems', {"bundler"=>{}}),
    $install_dir    = undef,
) {

  case $facts['os']['family'] {
    'windows': {
      $_version     = any2array($version)[0]
      $_install_dir = pick($install_dir, 'c:\tools')
      $ruby_dir     = regsubst($_version, '(\d)\.(\d)\.(\d)\.?(\d+)?', 'ruby\1\2\3')
      $ruby_home    = "${_install_dir}\\${ruby_dir}\\bin"

      package { 'ruby':
        ensure   => $_version,
        provider => chocolatey,
      }

      # Make sure the current Chocolatey installed Ruby comes first in PATH
      # (as opposed to other Rubies installed by builds, old versions, etc.)
      windows_env { 'PATH':
        ensure    => present,
        value     => $ruby_home,
        mergemode => prepend,
      }

      if $gems {
        $gems.each |$gem, $opts| {
          $gem_version = pick($opts['version'], '>= 0')
          $path = pick($opts["path"], $ruby_home)

          exec { "gem install ${gem} ${version}":
            path    => $path,
            command => "gem.bat install ${gem} --version \"${gem_version}\"",
            unless  => "gem.bat list ${gem} --installed --version \"${gem_version}\"",
          }
        }
      }
    }

    'RedHat', 'Suse': {
      # pick the first defined ruby as the default version
      $ruby_home    = "${install_dir}/version/${version[0]}"

      class { '::rbenv':
        install_dir => $install_dir,
      }

      $gem_defaults = {
        ruby_version => $version
      }

      rbenv::plugin { [ 'rbenv/rbenv-vars', 'rbenv/ruby-build' ]: }

      any2array($version).each |$v| {
        rbenv::build { $v:
          global => false,
        }

        $gems.each |$gem, $opts| {
          rbenv::gem { "ruby_${v}_gem_${gem}":
            gem          => $gem,
            ruby_version => $v,
            *            => $opts,
          }
        }
      }

    }
    default: {
      fail("#{name} does not support ${facts['os']['family']}")
    }
  }

  # set a global ruby_home variable
  environment_variable::variable{ "RUBY_HOME=${ruby_home}": }
}
