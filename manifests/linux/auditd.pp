# Redhat_tidy::Audit
#
# Ensure the audit service is installed, running and has a fixed set of rules
# loaded
#
# @param rules String of rules to add to /etc/audit/audit.rules
# @param manage_package True to ensure the audit package is installed otherwise
#   do nothing
# @param manage_service True to ensure the audit service is running otherwise do
#   nothing
# @param refresh_after_rules True to HUP the auditd service after a rule change
#   else do nothing.  Note that this works independently of overall service
#   management with the `manage_service` parameter
class r_profile::linux::audit(
    String  $rules                = '',
    Boolean $manage_package       = true,
    Boolean $manage_service       = true,
    Boolean $refresh_after_rules  = true,
) {
  $package      = "audit"
  $service      = "auditd"
  $rule_file    = "/etc/audit/audit.rules"
  $refresh_exec = "refresh_auditd"

  if $refresh_after_rules {
    $notify = "Exec[${refresh_exec}]"
  } else {
    $notify = undef
  }

  if $manage_package {
    $_package = $package
    package { $_package:
      ensure => present,
    }
  } else {
    $_package = undef
  }

  if $manage_service {
    service { $service:
      ensure  => running,
      enable  => true,
      require => Package[$_package],
    }
  }

  if $rules != '' {
    file { $rule_file:
      ensure  => file,
      owner   => "root",
      group   => "root",
      mode    => "0640",
      content => $rules,
      notify  => $notify,
    }
  }

  exec { $refresh_exec:
    refreshonly => true,
    command     => "pkill -P 1-HUP ${service}",
    path        => ["/usr/bin", "/bin"],
  }
}
