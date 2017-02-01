# R_profile::Webapp::Geoserver
#
# Support for install GeoServer - A server-side Java GIS
class r_profile::webapp::geoserver(
  $version          = '2.9.1',
  $download_base    = 'http://sourceforge.net/projects/geoserver/files/GeoServer',
  $lb               = true,
  $service_name     = 'geoserver',
  $nagios_monitored = true,
  $monitor_port     = 8080,
) {

  # tomcat
  include r_profile::web_service::tomcat

  $zip_filename   = "geoserver-${version}-war.zip"
  $download_url   = "${download_base}/${version}/${zip_filename}"
  $install_path   = "${r_profile::web_service::tomcat::catalina_home}/webapps/geoserver"
  $archive_dir    = "/var/cache/geoserver"
  $unpack_dir     = "${archive_dir}/geoserver-${version}"
  $war_file       = 'geoserver.war'
  $war_path       = "${unpack_dir}/${war_file}"
  $geoserver_dir  = '/var/lib/geoserver'
  $war_installed  = "${install_path}/META-INF/MANIFEST.MF"
  $data_dir       = "${geoserver_dir}/data"
  $gwc_dir        = "${geoserver_dir}/gwc"
  $user           = $r_profile::web_service::tomcat::user
  $group          = $r_profile::web_service::tomcat::group
  $catalina_home  = $r_profile::web_service::tomcat::catalina_home
  $service        = $r_profile::web_service::tomcat::service

  file { [ $install_path, $archive_dir, $unpack_dir ]:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Tomcat::Install[$catalina_home],
  }

  file { [ $geoserver_dir, $data_dir, $gwc_dir ]:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  # geoserver ships as a war inside a zip :-/ so we must extract locally
  # and then to the webapps dir

  archive { $zip_filename:
    path         => "/${archive_dir}/${zip_filename}",
    source       => $download_url,
    extract      => true,
    extract_path => $unpack_dir,
    creates      => $war_path,
    cleanup      => false,
    notify       => Exec['redeploy_geoserver'],
  }

  archive { $war_file:
    path         => $war_path,
    extract      => true,
    extract_path => $install_path,
    creates      => $war_installed,
    cleanup      => false,
    notify       => Tomcat::Service[$service],
  }

  # Delete any existing deployed geoserver
  exec { 'redeploy_geoserver':
    refreshonly => true,
    command     => "rm -rf ${install_path}/*",
    onlyif      => "test -f ${war_installed}",
    path        => ['/usr/bin','/bin'],
    before      => Archive[$war_file],
  }

  # geoserver should store data outside of webapps to prevent blowing it
  # away.  Take an initial copy from the extracted war file
  $changes = [
    "touch web-app/context-param[last()+1]/",
    "set web-app/context-param[last()]/param-name/#text GEOSERVER_DATA_DIR",
    "set web-app/context-param[last()]/param-value/#text ${data_dir}",
  ]


  augeas { "geoserver_web_xml":
    lens    => 'Xml.lns',
    incl    => "${install_path}/WEB-INF/web.xml",
    changes => $changes,
    require => Archive[$war_file],
    onlyif  => 'values web-app//context-param/param-name/#text not_include GEOSERVER_DATA_DIR'
  }


  # initial copy into GEOSERVER_DATA_DIR if needed
  exec { "geoserver_data_initial":
    command => "cp ${install_path}/data/* ${data_dir} -r && chown ${user}.${group} ${data_dir} -R",
    notify  => Tomcat::Service[$service],
    path    => [ '/usr/bin', '/bin'],
    creates => "${data_dir}/global.xml",
    require => Archive[$war_file],
  }

  if $nagios_monitored {
    nagios::nagios_service_http { 'geoserver':
      port => $monitor_port,
      url  => '/geoserver/web',
    }
  }

}
