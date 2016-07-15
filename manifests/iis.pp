class r_profile::iis(
  $website_owner  = hiera('r_profile::iis::website_owner', "IUSR_${hostname}"),
  $website_group  = hiera('r_profile::iis::website_group', 'Administrators'),
  $website_hash   = hiera('r_profile::iis::website_hash', {}),
  $ensure_default = hiera('r_profile::iss::ensure_default', present),
) {

  File {
    owner => $website_owner,
    group => $website_group,    
  }

  dsc_windowsfeature {'featureexample':
    dsc_ensure  => present,
    dsc_name    => 'Web-Server',
  }

  $default_acl = [
    {
      identity    => $website_owner,
      rights      => ['full'],
      perm_type   => 'allow',
      child_types => 'all',
      affects     => 'all'
    },
    {
      identity    => $website_group,
      rights      => ['full'],
      perm_type   => 'allow',
      child_types => 'all',
      affects     => 'all'
    }
  ]
  include ::iis

  Iis::Manage_app_pool {
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
  }

  # disable default website
  iis::manage_site { 'Default Web Site':
    ensure    => $ensure_default,
    site_path => 'C:\inetpub\wwwroot',
    app_pool  => 'Default Web Site',
  }

  iis::manage_app_pool { 'Default Web Site':
    ensure => $ensure_default,
  }

  $website_hash.each |String $site_name, Hash $website| {
    $_docroot = "C:\\inetpub\\wwwroot\\${website['docroot']}"

    iis::manage_app_pool { $site_name:
      ensure => present,
    }

    iis::manage_site { $site_name:
      site_path   => $_docroot,
      port        => '80',
      ip_address  => '*',
      host_header => $site_name,
      app_pool    => $site_name,
      before      => File[$site_name],
    }

    file { $site_name:
      ensure  => directory,
      path    => $_docroot,
    }

    acl { $_docroot:
      target                     => $_docroot,
      purge                      => false,
      permissions                => pick($website["acl"], $default_acl),
      owner                      => $website_owner,
      group                      => $website_group,
      inherit_parent_permissions => true,
    }
    file { $_docroot:
      ensure  => directory,
    }

    # Create a low-priority hello world page.  Customer content dropped in the
    # same directory will override this
    file { "${_docroot}/Iisstart.htm ":
      ensure  => file,
      content => $site_name,
    } 
  }
}

