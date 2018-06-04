# Custom fact to indicate whether where to store systemd/init environment files
Facter.add(:sysconf_dir) do
  confine :kernel => "Linux"
  setcode do
    case  Facter.value('os')['family']
    when "Debian"
      sysconf_dir = "/etc/default"
    when "RedHat"
      sysconf_dir = "/etc/sysconfig"
    when "Solaris"
      sysconf_dir = "/lib/svc/method"
    when "Suse"
      sysconf_dir = "/etc/sysconfig"
    else
      sysconf_dir = nil
    end

    sysconf_dir
  end
end