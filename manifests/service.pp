# @summary Ensure services are managed by Puppet to a particular state
#
# By default enable services to start on boot and be running.
#
# We take both a `base` and override hash of services and merge them to form a final list. This allows for simpler
# management through hiera.
#
# @example Hiera data to ensure service is enabled on boot and running
#   r_profile::service::services:
#     ntpd:
#     sshd
#
# @example Hiera data to ensure service stopped and not available on boot
#   r_profile::service::services:
#     xinetd:
#       ensure: stopped
#       enable: false
#
# @param base_services Base hash of services to manage (see examples)
# @param services Override hash of services to manage (see examples)
class r_profile::service(
    Hash[String, Optional[Hash]]  $base_services  = {},
    Hash[String, Optional[Hash]]  $services       = {},
) {

  merge($base_services, $services).each |$key, $opts| {
    service {
      default:
        ensure => running,
        enable => true,
      ;

      $key:
        * => pick($opts, {}),
    }
  }
}