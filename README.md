[![Build Status](https://travis-ci.org/declarativesystems/r_profile.svg?branch=master)](https://travis-ci.org/declarativesystems/r_profile)
# r_profile

#### Table of Contents

1. [Overview](#overview)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Overview

The `r_profile` module contains the profile equivalent of ready meals for Puppet.  The idea is that by offering a small selection of ready-to-use profiles, they can be reused amongst the puppet community without the need to repeatedly develop boilerplate code for common tasks.

The module itself contains many discrete profiles which become immediately available for use by installing the module.  Once installed, it is up to the user to select the appropriate classes to integrate into roles.  Think along the lines of picking out individual chocolates from a box rather then eating the whole thing and you've got the right idea.


## Usage

Most classes will need to be loaded using the `class` resource syntax in order to pass the appropriate class defaults, eg:

```puppet
class { "foo:bar":
  param1 => "value1",
  param2 => "value2",
}
```

Parameters, where available, are documented inside the individual classes.  See [Reference section](#reference).

### Hiera
Since these are profile classes, we are at the appropriate level to perform [Hiera](https://docs.puppet.com/hiera/3.2/) lookups directly.  Hiera lookups in `r_profile` classes are coded as class parameters and use explicit lookups using the [`hiera()` function](https://docs.puppet.com/puppet/latest/function.html#hiera), like this:

```puppet
# R_profile::Timezone
#
# Select the active system timezone (requires reboot).  Currently supports Linux,
# Solaris and AIX
#
# @param zone Timezone to set this node to, eg 'Asia/Hong_Kong'
class r_profile::timezone(
  $zone = hiera("r_profile::timezone::zone", undef),
) {
  ...
}
```

This affords the following conveniences:
* It's possible to assemble `r_profile` classes into `role` classes using the console to directly _include_ each class if desired
* Class parameters will automatically resolve to the key specified in the `hiera()` function
* If no suitable value can be found in hiera, the second argument to the `hiera()` function will be used as a default value (if present, otherwise an error will occur)
* If using the console, values can be overridden directly, per `r_profile` class, per node group
* All hiera keys are explicitly specified, while [Automatic parameter lookup](https://docs.puppet.com/hiera/3.3/puppet.html#automatic-parameter-lookup) could have been used instead, it appears somewhat _magical_ to casual users.  More importantly, hard coding the complete, correct hiera keys allows them to be pasted directly into your hiera `.yaml` files (or equivalent) without having to make sure you have concatenated the class and variable names with colons correctly

Setting our local timezone using the `r_profile::timezone` class is as simple as ensuring that we have the following value set in Hiera and resolvable for the node we are interested in configuring:

```json
r_profile::timezone::zone: "America/Nassau"
```

Each `r_profile` class parameter in classes intended for use are documented within the class it is defined in See [Reference section](#reference) for more information.


## Limitations

* Not supported by Puppet, Inc.
* Limited OS support
* Not all classes are fully functional!  Evaluate your chosen usage against the existing functionality.

## Development

PRs accepted :)

## Testing
This module supports testing using [PDQTest](https://github.com/GeoffWilliams/pdqtest).

* RSpec tests exist for most classes but https://tickets.puppetlabs.com/browse/MODULES-4287 makes this impossible for windows at present.
* The vsphere profile is prestently untestable as the module is enterprise-only

Test can be executed with:

```
bundle install
bundle exec pdqtest all
```
