# @summary Manage enivronment variables on windows and linux
#
# @see https://forge.puppet.com/geoffwilliams/environment_variable
#
# @example Basic usage
#   include r_profile::environment_variable
#
# @example Setting variables
#   r_profile::environment_variable::variables:
#     - "JAVA_HOME=/usr/local/jdk"
#     - "JAVA_OPTS='-Djava.awt.headless=true'"
#
# @param variables Array of variables to set in the form `variable=value` (see example)
class r_profile::environment_variable(
    Array[String] $variables = []
) {

  $variables.each |$variable| {
    environment_variable::variable { $variable:
      ensure => present,
    }
  }
}
