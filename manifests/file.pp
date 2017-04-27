# R_profile::File
#
# Support for managing files and directories
#
# @param files Hash of files to create (suitable for create_resources)
# @param directories Hash of directories to create (suitable for create_resources)
# @param process_template process the template() directive if found
class r_profile::file(
  $files             = hiera("r_profile::file::files", false),
  $directories       = hiera("r_profile::file::directories", false),
  $process_template = hiera("r_profile::file::process_template", false),
) {

  $default_directory  = { "ensure" => "directory"}
  $default_file       = { "ensure" => "file"}

  if $files {
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
          * => $default_file,
        ;
        $title:
          * => $_opts,
      }
    }
  }

  if $directories {
    create_resources("file", $directories, $default_directory)
  }
}
