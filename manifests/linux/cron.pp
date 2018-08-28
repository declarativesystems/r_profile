# @summary Restrict permissions on the `cron` scheduler
#
# Features:
# * Remove `cron.deny` so that only allowed users can run `cron`
# * Strict permissions on `at.allow`
# * Allow `root` to use `cron`
# * All files under `/var/spool/cron` owned by `root` with `0600` permissions (`crontab -e` will relax these)
#
# @see https://forge.puppet.com/geoffwilliams/chown_r
# @see https://forge.puppet.com/geoffwilliams/chmod_r
# @see https://forge.puppet.com/puppetlabs/stdlib
class r_profile::linux::cron {

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
}