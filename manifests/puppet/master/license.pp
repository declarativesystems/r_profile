# R_profile::Puppet::Master::License
#
# Install a puppet license key onto the puppet Master.  This works by symlinking
# the license.key file from your control repository to the correct location on
# the puppet master.  To upgrade or alter your license information, just update
# the file in the control repository (production branch) and then deploy to the
# master as usual.
#
# @example
#   include r_pofile::puppet::master::license
#
class r_profile::puppet::master::license {

  # puppet_enterprise module contains a resource to read and write the same file
  # which leaves us with only exec or resource collectors to do what we need to:
  # if !pe_empty($license_content) { # <-- the content of the file to write
  #                                        read previously using file(...)
  #   file { $puppet_enterprise::params::dest_license_key_path: # <-- same file
  #     ensure  => present,
  #     content => $license_content, # <-- same content
  #     mode    => '0644',
  #   }
  # }
  # This is of-course needed because the console might be on another system to
  # the puppet master (split installs)

  $license_source = "/etc/puppetlabs/code/environments/production/license.key"
  $license_target = "/etc/puppetlabs/license.key"

  # Copy in a licence file if diff says its non-existant or different.  We must
  # run after the code above otherwise we will be stuck in a race condition
  # where the file can never be updated
  exec { "copy pe license.key content":
    command => "cp ${license_source} ${license_target} && chmod +644 ${license_target}",
    unless  => "diff ${license_source} ${license_target}",
    path    => ["/usr/bin", "/bin"],
    require => Class["puppet_enterprise::license"],
  }
}
