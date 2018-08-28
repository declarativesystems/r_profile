# @summary Install and configure tomcat application server
#
# @see https://forge.puppet.com/puppetlabs/tomcat
#
# @param source_url URL to file to install tomcat from
# @param catalina_home Path to install tomcat
# @param service Name of the tomcat service
# @param user User to run tomcat as
# @param group Group for `user`
# @param port TCP port to run on
class r_profile::web_service::tomcat(
    String $source_url    = 'http://apache.mirror.amaze.com.au/tomcat/tomcat-8/v8.5.14/bin/apache-tomcat-8.5.14.tar.gz',
    String $catalina_home = '/opt/tomcat',
    String $service       = 'tomcat',
    String $user          = 'tomcat',
    String $group         = 'tomcat',
    Integer $port         = 8080,
){

  # for processing .war files
  ensure_packages('unzip', {'ensure' => 'present'})

  include r_profile::java

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
