# R_profile::Users
#
# Support for creating users and groups in bulk
class r_profile::users(
    $user_hash = hiera("r_profile::users::user_hash", false),
    $home_dir  = "/home",
    $groups    = hiera("r_profile::users::groups", [ "adm", "sudo"]),
) {
  if $user_hash {
    $users = keys($user_hash)

    # create a group for each user
    group { $users:
      ensure => present,
    }

    # create all users
    create_resources("user", $user_hash)

    # create all homedirs
    $users.each | $user | {
      file { "${home_dir}/${user}":
        ensure => directory,
        owner  => $user,
        group  => $user,
        mode   => "0700",
      }

      if $kernel != "windows" {
        # Add the user to sudo and adm groups if required
        $groups.each | $group | {
          augeas { "${user}_${group}_groups":
            context => "/files/etc/group/${group}",
            changes => "set user[last()] ${user}",
            onlyif  => "match user not_include ${user}",
          }
        }

        # copy in skeleton files, setup nice prompt, etc
        bash_user_skel { $user: }
      }
    }
  }

  # standardise the root user's login environment on non-windows systems
  if $kernel != "windows" {
    bash_user_skel { "root": }
  }
}
