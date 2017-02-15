# R_profile::Limit
#
# Manage Linux system limits using saz/limits
#
# @param purge True to remove unmanaged entries otherwise false
# @param settings Hash of limits settings to make
class r_profile::linux::limit(
    $purge    = hiera("r_profile::linux::limit::purge", false),
    $settings = hiera("r_profile::linux::limit::settings", {}),
) {
  class { 'limits':
    purge_limits_d_dir => $purge,
  }

  create_resources("limits::limits", $settings)

}
