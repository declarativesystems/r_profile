# @summary Setup the system package repositories
#
# Declare (instantiate) the required profile classes in a stage before `main`: `repo`.
# The reason for this class to exist is because it is not possible for classes to
# self-define their own runstage. It _must_ be passed using resource style class
# declaration as a simple string.
#
# @see https://puppet.com/docs/puppet/5.5/lang_run_stages.html
#
# @example Declare all requested repositories, setting up the `repo` runstage
#   include profile::repo
#
# @example Providing the list of repository profiles to load
#   r_profile::repo::profiles:
#     - r_profile::linux::yumrepo
#
# @param profiles Array of profile classes to load in the `repo` stage
# @param stage_name Name of the stage to process repositories in (before `main`)
class r_profile::repo(
    Array[String] $profiles   = [],
    String        $stage_name = "repo"
) {

  stage { $stage_name:
    before => Stage["main"],
  }

  # Normally I'd suggest avoiding includes based on hiera data but there isn't really
  # an alternative since we want to set the runstage and still allow profiles to be
  # assembled using simple includes
  $profiles.each |$profile| {
    class { $profile:
      stage => $stage_name,
    }
  }

}