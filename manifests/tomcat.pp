class r_profile::tomcat(
  $source_url     = 'http://apache.mirror.digitalpacific.com.au/tomcat/tomcat-8/v8.5.5/bin/apache-tomcat-8.5.5.tar.gz',
  $catalina_home  = '/opt/tomcat',
  $service        = 'tomcat',
  $user           = 'tomcat',
  $group          = 'tomcat',
){

  include java
  
  class { 'tomcat':
    catalina_home => $catalina_home,
    user          => $user,
    group         => $group,
  }

  tomcat::install { $catalina_home:
    source_url => $source_url,
  }

  tomcat::service { $service: 
    require => Tomcat::Install[$catalina_home]
  }

}
