# @summary Setup the system yum repos
#
# Items to create are grouped into base and non-base to allow easy management in Hiera. Items in non-base can override
# those in base.
#
# @see https://puppet.com/docs/puppet/5.5/types/yumrepo.html
#
# @example Puppet code to define a stage and run this class in it
#   stage { "yumrepos":
#     before => Stage["main"],
#   }
#   class { "r_profile::linux::yumrepo"
#     stage => "yumrepos"
#   }
#
# @example Alternatively, use the `r_profile::repo` class to instantate this class
#   # must add _this_ class to the list of classes to include `r_profile::repo::profiles`
#   include r_profile::repo
#
# @example Hiera data to setup a custom hosted yum repository
#   r_profile::linux::yumrepo:yumrepos
#     Artifactory:
#       baseurl: http://artifactory.megacorp.com
#       enabled: 1
#       gpgcheck: 0
#
# @param base_yumrepos Hash of yum repositories to ensure (base)
# @param yumrepos Hash of yum repositories to ensure (overrides)
class r_profile::linux::yumrepo(
    Hash[String, Hash]  $base_yumrepos  = {},
    Hash[String, Hash]  $yumrepos       = {},
) {


  ($base_yumrepos + $yumrepos).each |$key, $opts| {
    yumrepo {
      default:
        ensure => present,
      ;
      $key:
        * => $opts,
    }
  }
}