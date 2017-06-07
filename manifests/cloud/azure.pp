# R_profile::Cloud::Azure
#
# Manage the azure VMs using the passed-in hash
#
class r_profile::cloud::azure(
    Hash    $azure_vm               = hiera('r_profile::cloud::azure::azure_vm', {}),
    Hash    $azure_vm_default       = hiera('r_profile::cloud::azure::azure_vm_default', {}),
    Optional[String] $install_puppet_windows_cmd    = hiera('r_profile::cloud::azure::install_puppet_windows_cmd', undef),
    Optional[String] $install_puppet_linux_cmd    = hiera('r_profile::cloud::azure::install_puppet_linux_cmd', undef),
) {

  $challenge_password       = hiera('r_profile::puppet::master::autosign::secret',undef)
  $puppet_agent_install_key = "puppet_agent_install_key"

  # if we are inside one of the non root agents, also create the azure VMs
  $azure_vm.each |$title, $opts| {
    if has_key($opts, $puppet_agent_install_key) {
      case $opts[$puppet_agent_install_key] {
        "windows": {
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
                "protectedSettings"          => {
                  "commandToExecute"   => $puppet_install_windows_cmd,
                  # "storageAccountName" => $storage_account_name,
                  # "storageAccountKey"  => $storage_account_key,
                }
              }
            }
          }
        }
        "linux": {
          $extensions = {
            "CustomScriptForLinux" => {
              "auto_upgrade_minor_version" => true,
              "publisher"                  => 'Microsoft.Azure.Extensions',
              "type"                       => 'CustomScript',
              "type_handler_version"       => '2.0',
              "settings"                   => {
                "fileUris" => [
                  # - "https://gepuppetstore.file.core.windows.net/installscripts/installpe.sh"
                ],
                "protectedSettings" => {
                  "commandToExecute" => $puppet_install_linux_cmd,
                  # storageAccountName: "gepuppetstore"
                  # storageAccountKey: "KEY..."
                }
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
        $key == $puppet_agent_install_key
      }
    } else {
      $_opts      = $opts
      $extensions = undef
    }


    azure_vm {
      default:
        *          => $azure_vm_default,
        extensions => $extensions
      ;
      $title:
        * => $_opts,
    }
  }
}
