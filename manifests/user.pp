# R_profile::User
#
# Support for creating users and groups in bulk
#
# @example Heira data to support deluxe users with SSH logon granted
#   r_profile::user::users:
#     alice:
#       password: '$6$5XEywcNV$3txL0NS1cdR2coRI5bl1H2Sp6WOv8TLYG/BO3QtaeMKTRu9vlUCrYW9sZxsdGruZMI3SP8/B.DE8bl7rPV3p80'
#       authorized_keys: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9qYQmWOu2ryYJpPGT1HJqmBFTxxzda+7TgERu17S2CCVT1DKhFmGk5Pc1h/B6R4vKV1Pqs\
#         +vBzhsNfOHROS2WlqNQlnIJkagCqAO7EXggt5mV0N8zxQ/a0CkS0ve3BjUGMt/X2Ol2LF3nXGJes+c6kU6AHFZHb/g4oQNsvDjxbl5hDUeBH4\
#         8NNf55JexyOGDH4EOg5G6634stqqa6ZqMX4/E4n0nPpb6BoaYSkNra+v3p1w7ZTm3stA8Nl8BZ1UkwmVxfEmGdXQ+c3lrwHlIJRGr6KgCjCjX\
#         tjK1sr2oRQc3j2yCGjPrI5M1eusipk8vLdsSkSm/dFzPQqpdtML3X root@agent.localdomain"
#   # refer https://stackoverflow.com/a/21699210 for the insane encoding rules for yaml
#   # note the backslash at end of line and quotes around the whole key. This ends up as
#   # a single line in the target file without needing a really long line in yaml
#
# @param users Hash of user resources to create (suitable for ensure_resources)
# @param groups Hash of group resources to create (suitable for ensure_resources)
# @param deluxe Popuplate all user resources listed with a cool skeleton of files
class r_profile::user(
    Hash[String, Optional[Hash]] $users  = hiera("r_profile::user::users", {}),
    Hash[String, Optional[Hash]] $groups = hiera("r_profile::user::groups", {}),
    Boolean $deluxe = hiera("r_profile::user::deluxe", false),
) {

  $users.each |$user, $opts| {
    # if homedir set, create it
    $home = pick(dig($opts, 'home'), "/home/${user}")

    # we must remove the keyname from the opts hash to create the user or
    # the user resource will barf
    $opts_safe = $opts.filter |$key, $value| {
      $key != "authorized_keys"
    }

    user {
      default:
        ensure => present,
      ;
      $user:
        * => $opts_safe
    }


    file { $home:
      ensure => directory,
      owner  => $user,
      group  => pick(dig($opts, 'gid'), $user),
      mode   => "0700",
    }

    if has_key($opts, 'authorized_keys') and $facts['kernel'] != 'windows' {
      sshkeys::manual { $user:
        home            => $home,
        group           => pick($opts['gid'], $user),
        authorized_keys => $opts['authorized_keys'],
      }
    }

    if $deluxe and $facts['kernel'] != 'windows'{
      # copy in skeleton files, setup nice prompt, etc
      bash_user_skel { $user: }
    }
  }


  $groups.each |$group, $opts| {
    group {
      default:
        ensure => present,
      ;
      $group:
        * => $opts,
    }
  }


}
