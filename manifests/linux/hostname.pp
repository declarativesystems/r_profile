# @summary Set the hostname using systemd and optionally the system IP address
#
# By default, set the hostname to match `certname` - the name of the signed
# certificate that puppet knows about.  This is useful for cloud environments
# such as azure that assign dnsdomains based on regions that cannot be changed
# to a sensible default
#
# @example Set the hostname based on the puppet `certname`
#   include r_profile::linux::hostname
#
# @param fqdn The fully qualified hostname that this host should use for all names
# @param ip The IP address of a corresponding entry to add to /etc/hosts if required
class r_profile::linux::hostname(
    String            $fqdn = hiera("r_profile::linux::hostname::fqdn", $trusted['certname']),
    Optional[String]  $ip   = hiera("r_profile::linux::hostname::ip", undef),
) {

  if $fqdn {

    exec { "set hostname to ${fqdn}":
      command  => "hostnamectl set-hostname ${fqdn}",
      unless   => "[[ \"$(hostnamectl status --static)\" == ${fqdn} ]]",
      path     => ['/usr/bin/', '/bin'],
      provider => shell,
    }

    if $ip {
      host { $fqdn:
        ensure => present,
        ip     => $ip,
      }
    }
  }
}
