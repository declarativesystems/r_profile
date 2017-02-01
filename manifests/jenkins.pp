# R_profile::Jenkins
#
# Support for Jenkins CI
class r_profile::jenkins {
  # jenkins is packaged with an old-style init script on RHEL
  package { "initscripts":
    ensure => present,
  }
  include ::jenkins
}
