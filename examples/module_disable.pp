#@PDQTest
class { "r_profile::linux::module_disable":
  disable_modules => [
    "foo",
    "bar",
    "baz",
  ]
}