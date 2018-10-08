# @summary Restrict permissions on the `cron` scheduler and setup jobs
#
# Features:
# * Remove `cron.deny` so that only allowed users can run `cron`
# * Strict permissions on `at.allow`
# * Allow `root` to use `cron`
# * All files under `/var/spool/cron` owned by `root` with `0600` permissions
#   (`crontab -e` will relax these)
# * Install cron jobs using `cron` resource
#
# @see https://forge.puppet.com/geoffwilliams/chown_r
# @see https://forge.puppet.com/geoffwilliams/chmod_r
# @see https://forge.puppet.com/puppetlabs/stdlib
# @see https://puppet.com/docs/puppet/5.5/types/cron.html
#
# @example Ensuring correct permissions on the cron sub-system
#   include r_profile::linux::cron
#
# @example Installing cron jobs with Puppet
#   r_profile::linux::cron::jobs:
#     'logrotate':
#       command: '/usr/sbin/logrotate'
#       user: 'root'
#       hour: 2
#       minute: 0
#
# @example Purge unmanaged cron jobs
#   r_profile::linux::cron::purge: false
#   # Note: Only applies to _user_ cron jobs (eg those that would be visible
#   # with `puppet resource cron`
#
# @param base_jobs Cron jobs to install (base)
# @param jobs Cron jobs to install (override)
# @param purge Purge unmanaged user cronjobs
class r_profile::linux::cron(
  Hash[String, Hash]  $base_jobs  = {},
  Hash[String, Hash]  $jobs       = {},
  Boolean             $purge      = false,
) {

  file { "/etc/cron.deny":
    ensure => absent,
  }

  file { "/etc/crontab":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0400",
  }

  file { "/etc/cron.allow":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0400",
  }

  chmod_r { "/var/spool/cron":
    want_mode => "0600",
  }

  chown_r { "/var/spool/cron":
    want_user  => "root",
    want_group => "root",
  }

  file_line { "/etc/cron.allow root":
    ensure => present,
    line   => "root",
    path   => "/etc/cron.allow"
  }

  resources { "cron":
    purge => $purge,
  }

  ($base_jobs + $jobs).each |$key, $opts| {
    cron { $key:
      * => $opts,
    }
  }
}