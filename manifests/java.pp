# R_profile::Java
#
# Install Java (openjdk) using puppetlabs/java
#
# @param version Version of OpenJDK to install or undef to install latest
class r_profile::java(
  $version = hiera('r_profile::java::version', undef)
) {


  case $facts['os']['family'] {
    'windows': {
      package { 'java.jdk':
        ensure   => pick($version, 'present'),
        provider => chocolatey,
      }
    }
    'suse', 'redhat': {
      class { "java":
        version => $version,
      }

      # custom fact inside puppetlabs-java supplies the java home
      if $facts['java_default_home'] {

        file { '/etc/profile.d/set_java_home.sh':
          ensure  => file,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => "export JAVA_HOME=${facts['java_default_home']}\nPATH=\$JAVA_HOME/bin:\$PATH"
        }
      }
    }
    default: {
      fail("${class_name} doens't support ${facts['os']['family']}")
    }
  }
}
