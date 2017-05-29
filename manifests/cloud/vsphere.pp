# R_profile::Cloud::Vsphere
#
# Setup the dependencies for the puppetlabs/vsphere forge module and manage the
# passed-in hash of VMs.
#
# The forge module uses some locally gems for Vsphere library in order
# to talk to the Vsphere Cloud.
class r_profile::cloud::vsphere(
  Optional[String]  $vsphere_host        = hiera('r_profile::cloud::vsphere::host', undef),
  Optional[String]  $vsphere_user        = hiera('r_profile::cloud::vsphere::user', undef),
  Optional[String]  $vsphere_password    = hiera('r_profile::cloud::vsphere::password', undef),
  Hash              $vsphere_vm         = hiera('r_profile::cloud::vsphere::vsphere_vm', {}),
  Hash              $vsphere_vm_default = hiera('r_profile::cloud::vsphere::vsphere_vm_default', {}),
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
