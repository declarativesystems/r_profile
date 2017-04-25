# R_profile::Environment_variable
#
# Manage enivronment variables on windows and linux
#
# @param variable Varliable to set in the form `variable=value`. Arrays accepted
class r_profile::environment_variable(
    $variable = hiera("r_profile::environment_variable::variable", []),
) {

  $_variable = any2array($variable)
  $_variable.each |$v| {
    environment_variable::variable { $v:
      ensure => present,
    }
  }
}
