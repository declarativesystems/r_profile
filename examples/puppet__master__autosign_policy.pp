#@PDQTest
class { "r_profile::puppet::master::autosign":
  ensure => "policy",
  secret => "topsecret",
}