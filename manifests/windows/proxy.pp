# @summary Set the windows system proxy using netsh
#
# @example hiera data enabling proxy
#   r_profile::windows::proxy::proxy_server: 'http=proxy.example.com;https=proxy.example.org'
#   r_profile::windows::proxy::exclusion: '<local>;*.example.org;*.example.com'
#
# @example turning off proxy server
#   r_profile::windows::proxy::ensure: absent
#
# @see https://forge.puppet.com/sathieu/winhttp_proxy/readme
#
# @param ensure `present` to setup proxy, `absent` to remove configuration
# @param proxy_server Proxy server to use in format for `netsh` see example
# @param exclusion Proxy exclusions in format for `netsh` see example
class r_profile::windows::proxy(
    Enum['present', 'absent'] $ensure = present,
    Optional[String] $proxy_server = undef,
    Optional[String] $exclusion = undef
) {

  winhttp_proxy { 'proxy':
    ensure       => $ensure,
    proxy_server => $proxy_server,
    bypass_list  => $exclusion
  }
}