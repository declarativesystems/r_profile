# 1.12.1 (2017-06-07)
* Fixup path to azure.conf

# 1.12.0 (2017-06-07)
* Refacter azure module for nested subscriptions and non-root users

# 1.11.2 (2017-06-07)
* yum group install development tools on RHEL to get gems to compile for azure
* Fix licence key handling

# 1.11.1 (2017-06-06)
* Support for setting the versions of `azure` and `azure-mgmt-* gems` as parameters

# 1.11.0 (2017-06-03)
* Support for automatically installing a license.key file from puppet control repository
* Support for setting the system hostname on linux (systemd)

# 1.10.0 (2017-05-31)
* Support for joining AD domains

# 1.9.0 (2017-05-30)
* Support for non-root puppet agent deployment (for cloud/proxying)
* Support for VSphere (untested) - thanks @nelg

# 1.8.1 (2017-05-26)
* Updated supported release of psquared

# 1.8.0 (2017-05-25)
* Support for Azure
* Support for NodeJS

# 1.7.2 (2017-05-25)
* Fixed a typo setting `JAVA_HOME`
