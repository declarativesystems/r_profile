# @summary Write PHP configuration file settings
#
# @param configs Hash of configuration filenames and values to write:
# ```puppet
# config_filename => {
#   owner => 'user',  # config file owner
#   group => 'group', # config file group
#   mode  => '0640',  # config file permissions
#   notify => RES,    # resources to notify on change
#   defines   => {},  # PHP define KVPs to write in key=>value format
#   vars      => {},  # PHP variable KVPs to write in key=>value format
# }
# ```
class r_profile::webapp::php_config(
    $configs = hiera('r_profile::webapp::php_config', {}),
) {

  $configs.keys.each | $config | {
    $notify = pick($configs[$config]['notify'], false)
    if $notify {
      $_notify = $notify
    } else {
      $_notify = undef
    }

    $file_mode = pick($configs[$config]['mode'], '0644')
    file { $config:
      ensure => file,
      owner  => pick($configs[$config]['owner'], 'root'),
      group  => pick($configs[$config]['group'], 'root'),
      mode   => $file_mode,
      notify => $_notify,
    }

    # defined values
    if $configs[$config]['defines'] {
      $configs[$config]['defines'].keys.sort.each | $def | {
        file_line { "${config}_${def}":
          ensure => present,
          path   => $config,
          line   => "define( '${def}', '${configs[$config]['defines'][$def]}' );",
          match  => "^define( '${def}'",
          notify => $_notify,
        }
      }
    }

    # variables
    if $configs[$config]['vars'] {
      $configs[$config]['vars'].keys.sort.each | $v | {

        file_line { "${config}_${v}":
          ensure => present,
          path   => $config,
          line   => "\$${v} = '${configs[$config]['vars'][$v]}';",
          match  => "^\\\$${v}\s*=",
          notify => $_notify,
        }
      }
    }
  }
}
