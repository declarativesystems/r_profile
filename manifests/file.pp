class r_profile::file(
  $files        = hiera("r_profile::file::files", false),
  $directories  = hiera("r_profile::file::directories", false),
) {

  $default_directory  = { "ensure" => "directory"}
  $default_file       = { "ensure" => "file"}

  if $files {
    create_resources("file", $files, $default_file)
  }

  if $directories {
    create_resources("file", $directories, $default_directory)
  }
}
