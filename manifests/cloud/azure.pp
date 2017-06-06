# R_profile::Cloud::Azure
#
# Setup the dependencies for the puppetlabs/azure forge module and manage the
# passed-in hash of VMs.
#
# The forge module uses a locally installed copy of the Azure library in order
# to talk to the Azure Cloud.  There are presently two versions of this library:
# * `azure` command via the Azure xplat-cli (older, written in nodejs)
# * `az` command via Azure CLI 2.0 (newer, written in python)
#
# v1.x of forge module uses the xplat-cli and that is what this profile sets up
# for you.
#
# @see https://github.com/Azure/azure-xplat-cli

# puppet module install puppet-nodejs --version 2.3.0
#
# @param subscriptions Hash of subscriptions with the format:
#   ```
#     subscription_name = {
#       subscription_id    => "the_subscription_id",
#       tenant_id          => "the_tenant_id",
#       client_id          => "the_client_id",
#       client_secret      => "the_client_secret",
#       user               => "local linux user to run as",
#       homedir            => "home dir to install puppet agent",
#       puppet_master_fqdn => "fqdn.of.puppetmaster",
#     }
#   ```
#   * subscription_id The subsciption ID to provision ID to work with,
#     obtainedfrom billing page in azure portal
#   * tenant_id The active directory tennant ID to work with, see
#     https://stackoverflow.com/a/41028320/3441106
#   * client_id This is the equivalent of a username and involves registering
#     an application in the Azure AD instance.  Once registered, the field to use
#     here is `application_id`.  We don't use `object_id` at all.  Important:
#     Once the user has been created, it needs to be given RBAC access to the
#     Azure API which is done through the billing -> subscriptions menu
#     @see https://docs.bmc.com/docs/cloudlifecyclemanagement/46/setting-up-a-tenant-id-client-id-and-client-secret-for-azure-resource-manager-provisioning-669202145.html
#   * client_secret This is the equivalent of a password for the above user
#     and can be found by following the above tutorial
#
# @param azure_gem_version Specify the version of the `azure` gem to use to talk
#   to the azure API - useful if you need to use a newer version of the
#   `puppetlabs-azure` module
# @param azure_mgmt_gem_version Specify the version of the `azure-mgmt-*` gems to
#   use to talk to the azure API - useful if you need to use a newer version of
#   the `puppetlabs-azure` module
class r_profile::cloud::azure(
    Hash    $subscriptions          = hiera('r_profile::cloud::azure::subscriptions', {}),
    Hash    $azure_vm               = hiera('r_profile::cloud::azure::azure_vm', {}),
    Hash    $azure_vm_default       = hiera('r_profile::cloud::azure::azure_vm_default', {}),
    String  $azure_gem_version      = hiera('r_profile::cloud::azure::azure_gem_version',"0.7.9"),
    String  $azure_mgmt_gem_version = hiera('r_profile::cloud::azure::azure_mgmt_gem_version', "0.3.1")
) {

  $challenge_password = hiera('r_profile::puppet::master::autosign::secret',undef)


  # The gems need a bunch of development libraries to compile properly so use
  # the yum group install command
  package { "Development Tools":
    ensure   => present,
    provider => yum_group,
  }

  include r_profile::nodejs


  ensure_packages(
    [
      'gcc',
      'libffi-devel',
      'python-devel',
      'openssl-devel',
      'perl-Digest-SHA'
    ],
    {
      ensure => present
    }
  )

  package { 'azure-cli':
    ensure   => 'present',
    provider => 'npm',
  }


  # Azure module very picky about what rubygems to use so we pin exact versions.
  # Using a gem that is too new will give ruby errors like this:
  #   Error: Could not run: Puppet detected a problem with the information
  #   returned from Azure when accessing azure_vm. The specific error was:
  #   undefined method `value' for #<Array:0x000000057af3c8>
  package { "hocon":
    ensure   => "1.1.3",
    provider => "puppet_gem",
  }

  package { "retries":
    ensure   => "0.0.5",
    provider => "puppet_gem",
  }

  package { "azure":
    ensure   => $azure_gem_version,
    provider => "puppet_gem",
  }

  package { [ "azure_mgmt_compute", "azure_mgmt_network", "azure_mgmt_resources", "azure_mgmt_storage"]:
    ensure   => $azure_mgmt_gem_version,
    provider => "puppet_gem",
  }



  $subscriptions.each |$certname, $opts| {

    # create a non-root puppet agent for each subscription ID
    puppet_nonroot { $certname:
      puppet_master_fqdn => $opts['puppet_master_fqdn'],
      user               => $opts['user'],
      homedir            => $opts['homedir'],
      challenge_password => $challenge_password,
    }

    # If all required authentication fields are present, manage the azure.conf
    # file and its content, otherwise leave it alone.  This allows it to be
    # populated by other methods if necessary
    if $opts['subscription_id'] and $opts['tenant_id'] and $opts['client_id'] and $opts['client_secret'] {
      $homedir = pick($opts['homedir'], "/home/${opts['user']}")

      $puppet_conf_dir = "${homedir}/.puppetlabs/puppet"

      file { $puppet_conf_dir:
        ensure => directory,
        owner  => $opts['user'],
        group  => $opts['group'],
        mode   => '0700',
      }

      file { "${puppet_conf_dir}/azure.conf":
        ensure  => file,
        owner   => $opts['user'],
        group   => $opts['group'],
        mode    => '0600',
        content => epp("${module_name}/cloud/azure/azure.conf.epp", {
            subscription_id => $opts['subscription_id'],
            tenant_id       => $opts['tenant_id'],
            client_id       => $opts['client_id'],
            client_secret   => $opts['client_secret'],
        }),
      }
    }
  }


  # if we are inside one of the non root agents, also create the azure VMs
  if $trusted['clientcert'] in $subscriptions.keys() {
    $azure_vm.each |$title, $opts| {
      azure_vm {
        default:
          * => $azure_vm_default,
        ;
        $title:
          * => $opts,
      }
    }
  }
}
