# R_profile::Grub
#
# Secure the Grub 1.x boot-loader (RHEL < 7)
# * Permisisons on /etc/grub.conf
# * remove any kernel commandline disabling selinux
# * force all kernels to boot with audit=1
# * optionally set a grub password
#
# @param password_hash md5 password hash for grub to use, generated by grub-md5-crypt
# @param mode File mode for grub config file
class r_profile::linux::grub(
    $password_hash = false,
    $mode          = "0600",
) {

  $file     = "/etc/grub.conf"
  $tempfile = "${file}.tmp"

  file { $file :
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => $mode,
  }

  # Remove all instances of selinux=0 from /etc/grub.conf
  #
  # Wanted to use augeas here but the provider seems non-functional (missing
  # package?)
  #
  #   grub_config { "selinux":
  #     ensure => absent,
  #   }
  #
  # Results in
  #   Error: Could not find a suitable provider for grub_config
  #
  # So use a simple sed -i instead :/
  exec { "remove /etc/grub.conf selinux=0":
    command => "sed -i 's/selinux=0//g' ${file}",
    onlyif  => "grep 'selinux=' ${file}",
    path    => ['/usr/bin', '/bin'],
  }

  # enable kernel auditing as default if not specified (audit=1 at top of file)
  # - bonus points, update the unless line and do this all with awk
  file_line { "add /etc/grub.conf audit=1 (default options)":
    ensure => present,
    path   => $file,
    line   => "audit=1",
    match  => "^audit=",
    after  => "^default",
  }

  $awk_script='awk \' {
      gsub(/audit=0/,"audit=1", $0)
      if (match($0, "^[[:space:]]*kernel"))
        if (match($0, "audit=1"))
    	print $0
        else
    	print $0 "audit=1"
      else
        print $0
    } \' '

  # enable kernel auditing (audit=1 on every kernel command line)
  exec { "add /etc/grub.conf audit=1 (every kernel) and replace all instances of audit=0 with =1":
    command => "${awk_script} < ${file} > ${tempfile} && mv ${tempfile} ${file} && chmod ${mode} ${file}",
    unless  => "bash -c \"! grep '^[[:space:]]*kernel' ${file} | grep -v audit=1 && ! grep audit=0 ${file}\"",
    path    => ['/bin', '/usr/bin'],
  }

  # only set password on physical machines when parameter set
  if $facts['virtual'] == 'physical' and $password_hash {
    file_line { "/etc/grub.conf password":
      ensure => present,
      path   => $file,
      line   => "password --md5 ${password_hash}",
      match  => "^password ",
      after  => "^default",
    }
  }
}