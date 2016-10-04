class r_profile::nagios_server(
    4$password = hiera("r_profile::nagios_server::password", "nagios"),
    
) {
  include nagios
  class { "nagios::server":
    password => $password,
  }

  if $enable_firewall and !defined(Firewall["100 ${::fqdn} HTTP ${website_port}"]) {
    firewall { "100 ${::fqdn} HTTP ${port}":
      dport   => $port,
      proto   => 'tcp',
      action  => 'accept',
    }
  }
}
