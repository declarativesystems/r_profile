# @summary Set the system supported runlevels
#
# @param runlevels String containing allowed runlevels
class r_profile::linux::inittab(
    String $runlevels = "3",
) {

  augeas{"inittab runlevel":
    context => "/files/etc/inittab",
    changes => "set /files/etc/inittab/id/runlevels 3",
  }

}
