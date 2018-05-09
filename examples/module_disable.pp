#@PDQTest
class { "r_profile::linux::module_disable":
  modules => [
    "foo",
    "bar",
    "baz",
  ]
}