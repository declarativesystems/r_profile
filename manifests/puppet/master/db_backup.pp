# @summary Install a cron job to backup the PE postgres server
#
# @note Takescomplete dump of the database
#
# @param ensure `present` to create the cron job, `absent` to remove it
# @param dir Directory to dump database to
# @param hour Cron hour to commence database dump
# @param minute Cron minute to commence database dump
# @param month Cron month to commence database dump
# @param monthday Cron monthday to commence database dump
# @param weekday Cron weekday to commence database dump
class r_profile::puppet::master::db_backup(
    Enum['present', 'absent'] $ensure   = hiera("r_profile::puppet::master::db_backup::ensure",   "present"),
    String $dir      = hiera("r_profile::puppet::master::db_backup::dir",      "/tmp"),
    String $hour     = hiera("r_profile::puppet::master::db_backup::hour",     "5"),
    String $minute   = hiera("r_profile::puppet::master::db_backup::minute",   "0"),
    String $month    = hiera("r_profile::puppet::master::db_backup::month",    "*"),
    String $monthday = hiera("r_profile::puppet::master::db_backup::monthday", "*"),
    String $weekday  = hiera("r_profile::puppet::master::db_backup::weekday",  "*"),
) {

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
