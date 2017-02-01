# R_profile::Aws
#
# Configure AWS with puppet
class r_profile::aws(
  $aws_access_key_id          = hiera("r_profile::aws::aws_secret_key_id"),
  $aws_secret_access_key      = hiera("r_profile::aws::aws_secret_access_key"),
  $ec2_instance               = hiera("r_profile::aws::ec2_instance", {}),
  $ec2_instance_default       = hiera("r_profile::aws::ec2_instance_default", {}),
  $ec2_securitygroup          = hiera("r_profile::aws::ec2_securitygroup", {}),
  $ec2_securitygroup_default  = hiera("r_profile::aws::ec2_securitygroup_default", {}),
  $elb_loadbalancer           = hiera("r_profile::aws::elb_loadbalancer", {}),
  $elb_loadbalancer_default   = hiera("r_profile::aws::elb_loadbalancer_default", {}),
  # ... add more later

) {


  File {
    owner => "root",
    group => "root",
    mode  => "0600",
  }

  package { [ "aws-controlrepo", "retries", ]:
    ensure   => present,
    provider => "puppet_gem",
  }

  file { "/root/.aws":
    ensure => directory,
  }

  file { "/root/.aws/credentials":
    ensure  => file,
    content => template("modules/r_profile/aws/credentials.erb"),
  }

  create_resources("ec2_instance", $ec2_instance, $ec2_instance_default)
  create_resources("ec2_securitygroup", $ec2_securitygroup, $ec2_securitygroup_default)
  create_resources("elb_loadbalancer", $elb_loadbalancer, $elb_loadbalancer_default)

}
