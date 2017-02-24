# R_profile::Puppet::Master::Db_backup
#
# Install a cron job to backup the PE postgres server by taking a complete dump
# of the database
#
# @param ensure `present` to create the cron job, `absent` to remove it
# @param dir Directory to dump database to
# @param hour Cron hour to commence database dump
# @param minute Cron minute to commence database dump
# @param month Cron month to commence database dump
# @param monthday Cron monthday to commence database dump
# @param weekday Cron weekday to commence database dump
class r_profile::puppet::master::db_backup(
    $ensure   = hiera("r_profile::puppet::master::db_backup::ensure",   'present'),
    $dir      = hiera("r_profile::puppet::master::db_backup::dir",      $r_profile::puppet::params::db_backup_dir),
    $hour     = hiera("r_profile::puppet::master::db_backup::hour",     $r_profile::puppet::params::db_backup_hour),
    $minute   = hiera("r_profile::puppet::master::db_backup::minute",   $r_profile::puppet::params::db_backup_minute),
    $month    = hiera("r_profile::puppet::master::db_backup::month",    $r_profile::puppet::params::db_backup_month),
    $monthday = hiera("r_profile::puppet::master::db_backup::monthday", $r_profile::puppet::params::db_backup_monthday),
    $weekday  = hiera("r_profile::puppet::master::db_backup::weekday",  $r_profile::puppet::params::db_backup_weekday),
) inherits r_profile::puppet::params {

  cron { "pe_database_backups":
    ensure      => $ensure,
    command     => "pg_dumpall -c -f ${dir}/pe_postgres_$(date --iso-8601).bin",
    user        => "pe-postgres",
    hour        => $hour,
    minute      => $minute,
    month       => $month,
    monthday    => $monthday,
    weekday     => $weekday,
    environment => "PATH=/opt/puppetlabs/server/bin:/opt/puppetlabs/bin:/opt/puppet/bin/:/usr/local/bin:/usr/bin:/bin",
  }
}
