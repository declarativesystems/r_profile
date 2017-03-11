# Systemd_active
#
# Custom fact to indicate whether Systemd is active on linux or not.
Facter.add(:systemd_active) do
  confine :kernel => "Linux"
  setcode do
    Facter::Core::Execution.exec('ps 1|grep systemd && echo "true" || echo "false"')
  end
end
