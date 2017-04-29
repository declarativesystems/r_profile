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
      package { 'jdk7':
        ensure   => pick($version, 'present'),
        provider => chocolatey,
      }

      # unclear where chocolatey installs java on windows, however its install
      # script seems to set its own `JAVA_HOME` so we won't duplicate here.
    }
    'suse', 'redhat': {
      class { "java":
        version => $version,
      }

      # custom fact inside puppetlabs-java supplies the java home
      $java_home = pick($facts['java_default_home'], false)
    }
    default: {
      fail("${class_name} doens't support ${facts['os']['family']}")
    }
  }

  if $java_home {
    environment_variable::variable{"JAVA_HOME=${java_home}": }
    environment_variable::path_element{"${java_home}}/bin": }
  }
}
