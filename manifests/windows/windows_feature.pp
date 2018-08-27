# R_profile::Windows::Windows_feature
#
# Install Windows Features using Puppet and reboot if required.
#
# Rebooting is controlled adding an additional parameter `reboot_after` to the data fed
# to this profile. _This_ class will act on this directive itself by subscribing its own
# `reboot` resource to any windows features decorated with this parameter.
#
# We will remove the `reboot_after` attribute from the hash of options passed to the real
# `windows_feature` resource to prevent an error about unknown parameters.
#
# Items to create are grouped into base and non-base to allow easy management in Hiera. Items in non-base can override
# those in base.
#
# @see https://forge.puppet.com/puppet/windowsfeature
# @see https://forge.puppet.com/puppetlabs/reboot
#
# @example basic usage
#   include r_profile::windows::windows_feature
#
# @example Hiera data to install windows features
#   r_profile::windows::windows_feature::features:
#     'Web-Server':
#     'Web-WebServer':
#       installmanagementtools: true
#       reboot_after: true
#
# @param base_features Hash of windows features to install (base)
# @param features Hash of windows features to install (override)
class r_profile::windows::windows_feature(
    Hash[String, Optional[Hash]] $base_features = {},
    Hash[String, Optional[Hash]] $features      = {},
) {

  # build an array of references to `windowsfeature` instances that will
  # required a reboot. This will be intersperced with `undef` where no
  # reboot is required. The logic behind the `subscribe` metaparameter
  # ignores these.
  $reboot_after = ($base_features + $features).map |$key, $opts| {
    # options input to lambda, coaleseced to hash if absent
    $opts_in = pick($opts, {})

    # remove our custom `reboot_after` parameter from the list so that
    # we can pass it to `windowsfeature` without error
    $opts_safe = $opts_in.filter |$k,$o| {
      $k  !=  "reboot_after"
    }


    windowsfeature {
      default:
        ensure => present,
      ;
      $key:
        * => pick($opts_safe, {}),
    };

    # Return either a reference to _this_ windows feature if we are supposed to reboot
    # or undef if we are not
    pick(dig($opts_in, "reboot_after"), false)  ? {
      true  => Windowsfeature[$key],
      false => undef,
    }

  }

  reboot {'after_windows_feature':
    when      => pending,
    subscribe => $reboot_after,
  }
}