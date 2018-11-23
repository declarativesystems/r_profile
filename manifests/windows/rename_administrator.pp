# @summary Rename the `administrator` account.
#
# After renaming the `administrator` account, we should immediately reboot the
# system since the account we're currently running from (if interactive) will
# lose its 'magic' until restarted.
#
# @see https://forge.puppet.com/puppetlabs/reboot
#
# @example basic usage
#   include r_profile::windows::rename_administrator
#
# @example specifying the account to rename to
#   r_profile::windows::rename_administrator::admin_account: "siteadmin"
#
# @param account New name for the `administrator` account. You must configure this
#   or no action will be taken
class r_profile::windows::rename_administrator(
    Optional[String] $account = undef,
) {

  if $account {
    # The backticks are to protect the quotes from powershell
    # https://stackoverflow.com/a/14132476/3441106
    exec { "rename administrator account to ${account}":
      provider => powershell,
      onlyif   => "wmic useraccount where name=`\"administrator`\" | findstr AccountType",
      command  => "wmic useraccount where name=`\"administrator`\" rename `\"${account}`\"",
      path     => ['c:/windows/system32', 'c:/windows/system32/wbem']
    }

    ~> reboot { "administrator account renamed": }
  }
}