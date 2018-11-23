# @summary Support for ordering operations before the main puppet run
#
# Some operations need to be caried out before the main puppet run in order to
# avoid errors from later on in the run where a breaking change requiring an
# immediate reboot is required.
#
# The main culpret today is the renaming of the Windows `Administrator` account
# which causes interactive puppet runs to immediately _break_. Since this is a
# one-off independent change, run stages are used rather then attempting to
# enumerate and collect every other resource on the platform
#
# @see https://puppet.com/docs/puppet/5.5/lang_run_stages.html
#
# @example Selecting the classes to run before stage `main`
#   profile::windows::pre_stage::classes:
#     - "profile::windows::rename_administrator"
#
# @param stage_name Name of the stage to create
# @param classes List of classes to run in the `pre` stage. Puppet will still
#   honour automatic parameter lookup from hiera, despite the resource style
#   class instantiation
class r_profile::windows::pre_stage(
  String        $stage_name = "pre",
  Array[String] $classes    = [],
) {

  stage { $stage_name:
    before=>Stage["main"]
  }

  $classes.each |$c| {
    class { $c:
      stage => $stage_name,
    }
  }
}