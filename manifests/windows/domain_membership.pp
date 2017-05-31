# R_profile::Windows::Domain_membership
#
# Join an Active Directory domain using Puppet and the trlinkin/domain_membership
# module using data from Hiera
#
# @example Join a domain
#   include r_profile::windows::domain_membership
#
# @param domain AD domain which the node should be a member of.
# @param username User with ability to join machines to a Domain.
# @param password Password for domain joining user.
# @param machine_ou OU in the directory for the machine account to be created in.
# @param resetpw Whether or not to force machine password reset if it becomes
#   out of sync with the domain.
# @param reboot Whether or not to reboot when the machine joins the domain.
# @param join_options A bit field for options to use when joining the domain.
#   A value of '1' indicates default domain join (the default)
#   @see http://msdn.microsoft.com/en-us/library/aa392154(v=vs.85).aspx
# @param user_domain Domain of user account used to join machine, if different
#   from domain machine will be joined to. If not specified, the value passed to
#   the domain parameter will be used.
class r_profile::windows::domain_membership(
  String            $domain       = hiera("r_profile::windows::domain_membership::domain"),
  String            $username     = hiera("r_profile::windows::domain_membership::username"),
  String            $password     = hiera("r_profile::windows::domain_membership::password"),
  Optional[String]  $join_options = hiera("r_profile::windows::domain_membership::join_options", undef),
  Optional[String]  $machine_ou   = hiera("r_profile::windows::domain_membership::machine_ou", undef),
  Optional[String]  $resetpw      = hiera("r_profile::windows::domain_membership::resetpw", undef),
  Optional[String]  $reboot       = hiera("r_profile::windows::domain_membership::reboot", undef),
  Optional[String]  $user_domain  = hiera("r_profile::windows::domain_membership::user_domain", undef),
) {
  class { 'domain_membership':
    domain       => $domain,
    username     => $username,
    password     => $password,
    join_options => $join_options,
    machine_ou   => $machine_ou,
    resetpw      => $resetpw,
    reboot       => $reboot,
    user_domain  => $user_domain,
  }

}
