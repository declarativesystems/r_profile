# @suummary Setup the dependencies for the puppetlabs/vsphere forge module and VMs
#
# The forge module uses some locally gems for Vsphere library in order
# to talk to the Vsphere API
#
# @param vsphere_host hostname or IP address of vsphere server to talk to API as
# @param vsphere_user username for API
# @param vsphere_password password for API
# @param vsphere_vm Hash of VMs to create
# @param vsphere_vm_default Hash of default settings for creating VMs
class r_profile::cloud::vsphere(
    Optional[String]  $vsphere_host       = undef,
    Optional[String]  $vsphere_user       = undef,
    Optional[String]  $vsphere_password   = undef,
    Hash              $vsphere_vm         = {},
    Hash              $vsphere_vm_default = {},
) {
  ensure_packages(
    [
      'gcc',
      'libxslt-devel',
      'patch',
      'zlib-devel'
    ],
    {
      ensure => present
    }
  )
  # Vsphere module requires some rubygems
  package { "hocon":
    ensure   => "1.1.3",
    provider => "puppet_gem",
  }
  package { "rbvmomi":
    ensure          => "present",
    install_options => ['--no-ri','--no-rdoc'],
    provider        => "puppet_gem",
  }
  # If all required authentication fields are present, manage the vsphere.conf
  # file and its content, otherwise leave it alone.  This allows it to be
  # populated by other methods if necessary
  if $vsphere_host and $vsphere_user and $vsphere_password {
    file { "/etc/puppetlabs/puppet/vsphere.conf":
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => epp("${module_name}/cloud/vsphere/vsphere.conf.epp", {
          vsphere_user     => $vsphere_user,
          vsphere_password => $vsphere_password,
          vsphere_host     => $vsphere_host,
      }),
    }
  }
  $vsphere_vm.each |$title, $opts| {
    vsphere_vm {
      default:
        * => $vsphere_vm_default,
      ;
      $title:
        * => $opts,
    }
  }
}
