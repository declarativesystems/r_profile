# R_profile::Linux::Firewalld
#
# Manage firewalld using crayfishx-firewalld. Accepts base plus additional
# options for each set of rule resources being managed for easy managment
# using hiera.
#
# @see https://forge.puppet.com/crayfishx/firewalld
#
# @example hiera data for enabling free access to a service
#   r_profile::linux::firewalld::firewalld_service:
#     "allow ssh":
#       ensure: present
#       service: ssh
#     "allow puppetmaster":
#       ensure: present
#       service: "puppetmaster"
#     "allow puppet orchestrator":
#       ensure:  present
#       service: "puppet-orchestrator"
#     "allow https":
#       ensure: present
#       service: "https"
#
# @example hiera data for creating a rich rule
#   r_profile::linux::firewalld::firewalld_rich_rule:{}
#     'allow access to tomcat from internal':
#       ensure: present
#       zone: public
#       action: accept
#       source: '192.168.1.0/24'
#       port:
#         port: 8080
#         protocol: tcp
#
# @example disable firewalld
#   r_profile::linux::firewalld::service_ensure: stopped
#   r_profile::linux::firewalld::service_enable: false
#
# @param service_ensure How to ensure the `firewalld` service
# @param service_enable `true` to start firewalld on boot otherwise `false` to disable it
# @param base_firewalld_service base level `firewalld_service` rules (see examples)
# @param firewalld_service additional `firewalld_service` rules (see examples)
# @param base_firewalld_rich_rule base level `firewalld_rich_rule` rules (see examples)
# @param base_firewalld_rich_rule additional `firewalld_rich_rule` rules (see examples)
class r_profile::linux::firewalld(
    Enum['running', 'stopped']    $service_ensure           = 'running',
    Boolean                       $service_enable           = true,
    Hash[String, Optional[Hash]]  $base_firewalld_service   = {},
    Hash[String, Optional[Hash]]  $firewalld_service        = {},
    Hash[String, Optional[Hash]]  $base_firewalld_rich_rule = {},
    Hash[String, Optional[Hash]]  $firewalld_rich_rule      = {},
) {

  # Service definition for Puppet Orchestrator (8142) - PuppetMaster definition alreaady ships with RHEL7
  firewalld::custom_service{ "puppet-orchestrator":
    description => 'Puppet Orchestrator/PXP runs actions on agents via the Puppet Execution Protocol agent.',
    port        => [{
      'port'     => '8142',
      'protocol' => 'tcp',
    }],
  }

  class { "firewalld":
    service_ensure => $service_ensure,
    service_enable => $service_enable,
  }

  if $service_ensure == 'running' {
    firewalld_zone { "public":
      ensure           => "present",
      target           => "default",
      masquerade       => false,
      purge_rich_rules => true,
      purge_services   => true,
      purge_ports      => true,
    }

    merge($base_firewalld_service, $firewalld_service).each |$key, $opts| {
      firewalld_service {
        default:
          ensure => present,
        ;
        $key:
          * => $opts,
      }
    }

    merge($base_firewalld_rich_rule, $firewalld_rich_rule).each |$key, $opts| {
      firewalld_rich_rule {
        default:
          ensure => present,
        ;
        $key:
          * => $opts,
      }
    }
  }
}
