# R_profile::User
#
# Support for creating users and groups in bulk
#
# @param users Hash of user resources to create
# @param groups Hash of group resources to create
# @param deluxe Popuplate all user resources listed with a cool skeleton of files
class r_profile::user(
    $users  = hiera("r_profile::user::users", false),
    $groups = hiera("r_profile::user::groups", false),
    $deluxe = hiera("r_profile::user::deluxe", false),
) {

  $default_ensure = {'ensure' => 'present'}
  if $users {
    ensure_resources("user", $users, $default_ensure)

    $users.each |$title, $hash| {
      # if homedir set, create it
      $home = dig($hash, 'home')

      if $home {
        $homedir_group = pick(dig($hash, 'gid'), $title)
        $homedir = {
          $home => {
            "ensure" => "directory",
            "owner"  => $title,
            "group"  => $homedir_group,
            "mode"   => "0700",
          }
        }
        ensure_resources("file", $homedir)
      }

      if $deluxe {
        # copy in skeleton files, setup nice prompt, etc
        bash_user_skel { $user: }
      }
    }

  }

  if $groups {
    ensure_resources("group", $groups, $default_ensure)
  }


}
