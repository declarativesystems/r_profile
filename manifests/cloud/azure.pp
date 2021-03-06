# @summary Manage the azure VMs using the passed-in hash
#
# @param azure_vm Hash of azure VMs to create
# @param azure_vm_default Hash of default settings for azure VMs
# @param install_puppet_windows_cmd Command to run to install puppet on windows
# @param install_puppet_linux_cmd Command to run to install puppet on linux
# @param puppet_master_fqdn FQDN of Puppet master
# @param challenge_password Challenge password to use for autosigning
class r_profile::cloud::azure(
    Hash    $azure_vm                             = {},
    Hash    $azure_vm_default                     = {},
    Optional[String] $install_puppet_windows_cmd  = undef,
    Optional[String] $install_puppet_linux_cmd    = undef,
    Optional[String] $puppet_master_fqdn          = undef,
    Optional[String] $challenge_password          = undef,
) {

  # pick the selected password from hiera or use an empty string
  $_challenge_password = pick(
    $challenge_password,
    hiera('r_profile::puppet::master::autosign::secret',undef),
    "changeme",
  )
  $puppet_agent_install_key = "puppet_agent_install"

  $_install_puppet_windows_cmd  = pick(
    $install_puppet_windows_cmd,
    "powershell -ExecutionPolicy Unrestricted -Command \"[Net.ServicePointManager]::ServerCertificateValidationCallback = {\$true}; \$webClient = New-Object System.Net.WebClient; \$webClient.DownloadFile('https://${puppet_master_fqdn}:8140/packages/current/install.ps1', 'install.ps1'); .\\install.ps1\""
  )
  $_install_puppet_linux_cmd    = pick(
    $install_puppet_linux_cmd,
    "curl -k https://${puppet_master_fqdn}:8140/packages/current/install.bash | bash"
  )


  $azure_vm.each |$title, $opts| {
    if has_key($opts, 'certname') {
      $certname = $opts['certname']
    } else {
      $certname = $title
    }

    # if we are inside one of the non root agents, also create the azure VMs
    if has_key($opts, $puppet_agent_install_key) {
      case $opts[$puppet_agent_install_key] {
        "windows": {
          $cmd = "${_install_puppet_windows_cmd} main:certname=${certname} custom_attributes:challengePassword=${_challenge_password}"
          $extensions = {
            "CustomScriptExtension" => {
              "auto_upgrade_minor_version" => "true",
              "publisher"                  => 'Microsoft.Compute',
              "type"                       => 'CustomScriptExtension',
              "type_handler_version"       => '1.7',
              "settings"                   => {
                "fileUris" => [
                  # "https://gepuppetstore.file.core.windows.net/installscripts/installpe.ps",
                ],
                "commandToExecute"   => $cmd,
              }
            }
          }
        }
        "linux": {
          $cmd = "${_install_puppet_linux_cmd} -s agent:certname=${certname} custom_attributes:challengePassword=${_challenge_password}"
          $extensions = {
            "CustomScriptForLinux" => {
              "auto_upgrade_minor_version" => true,
              "publisher"                  => 'Microsoft.Azure.Extensions',
              "type"                       => 'CustomScript',
              "type_handler_version"       => '2.0',
              "settings"                   => {
                "fileUris" => [
                ],
                "commandToExecute" => $cmd,
              }
            }
          }
        }
        default: {
          fail("azure_vm ${title} must specify platform if installing a puppet agent")
        }
      }
      # remove our puppet_agent_install key or azure_vm will choke on it
      $_opts = $opts.filter |$key, $value| {
        $key != $puppet_agent_install_key and $key != "certname"
      }
    } else {
      $_opts      = $opts
      $extensions = undef
    }


    azure_vm {
      default:
        *          => $azure_vm_default,
        extensions => $extensions,
      ;
      $title:
        * => $_opts,
    }
  }
}
