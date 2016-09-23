class r_profile::source_ipaddress($target = undef) {
  class { "source_ipaddress":
    target => $target,
  }
}
