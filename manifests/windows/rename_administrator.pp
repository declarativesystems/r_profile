# R_profile::Windows::Rename_administrator
#
# Rename the `administrator` account.
#
# @example basic usage
#   include r_profile::windows::rename_administrator
#
# @example specifying the account to rename to
#   r_profile::windows::rename_administrator::admin_account: "siteadmin"
#
# @param admin_account New name for the `administrator` account. You must configure this
#   or no action will be taken
class r_profile::windows::rename_administrator(
    $admin_account = "administrator"
) {

  # The backticks are to protect the quotes from powershell
  # https://stackoverflow.com/a/14132476/3441106
  exec { "rename administrator account to ${admin_account}":
    provider => powershell,
    onlyif   => "wmic useraccount where name=`\"administrator`\" | findstr AccountType",
    command  => "wmic useraccount where name=`\"administrator`\" rename `\"${admin_account}`\"",
    path     => ['c:/windows/system32', 'c:/windows/system32/wbem']
  }
}