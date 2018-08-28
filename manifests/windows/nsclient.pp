# @summary Configure the NSClient++ software on Windows
#
# @example Basic usage
#   include r_profile::windows::nsclient
#
# @example Change settings in nsclient.ini
#   r_proflie::windows::nsclient::settings:
#     "/settings/NRPE/server":
#       ssl:
#         value: "true"
#       insecure:
#         value: "false"
#       "verify mode":
#         ensure: absent
#
# @param config_file Location of nsclient.ini
# @param service Name of the windows service for nsclient
# @param settings Hash of settings (see example)
class r_profile::windows::nsclient(
    String                                            $config_file  = 'C:\Program Files\NSClient++\nsclient.ini',
    String                                            $service      = "nscp",
    Hash[String, Hash[String, Hash[String, String]]]  $settings     = {},
) {

  # FIXME what to do with package??? chocolatey?

  # Write all requested settings to ini file
  $settings.each |$section, $data| {
    $data.each |$key, $opts| {
      ini_setting {
        default:
          ensure  => present,
          path    => $config_file,
          section => $section,
          setting => $key,
          notify  => Service[$service],
        ;
        "${config_file}/${section}/${key}":
          * => $opts,
      }
    }
  }

  service { $service:
    ensure => running,
    enable => true,
  }
}