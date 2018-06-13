# R_profile::File
#
# Support for managing files and directories
#
# @param files Hash of files to create (suitable for create_resources)
# @param process_template process the template() directive if found
class r_profile::file(
  $files             = hiera("r_profile::file::files", {}),
  $process_template = hiera("r_profile::file::process_template", false),
) {

  $files.each |$title, $opts| {
    if $process_template {
      if dig($opts, 'content') and $opts['content'] =~ /^template(.+)$/ {
        # process the template and return the content
        $template = regsubst($opts["content"], '^template\(([^)]+)\)$', '\1')
        $temp = {
          "content" => template($template)
        }
        # merge the hashes, allowing parsed content to override
        $_opts = merge($opts, $temp)
      }
    } else {
      $_opts = $opts
    }

    file {
      default:
        ensure => file,
      ;
      $title:
        * => $_opts,
    }
  }
}
