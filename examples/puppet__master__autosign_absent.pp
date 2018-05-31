#@PDQTest
group { "pe-puppet":
  ensure => present,
}
service { "pe-puppetserver": }
class { "r_profile::puppet::master::autosign":
  ensure => "absent",
}