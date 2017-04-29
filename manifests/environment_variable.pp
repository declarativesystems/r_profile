# R_profile::Environment_variable
#
# Manage enivronment variables on windows and linux
#
# @param variable Varliable to set in the form `variable=value`. Arrays accepted
class r_profile::environment_variable(
    $variables = hiera("r_profile::environment_variable::variables", []),
) {

  $_variables = any2array($variables)
  $_variables.each |$variable| {
    environment_variable::variable { $variable:
      ensure => present,
    }
  }
}
