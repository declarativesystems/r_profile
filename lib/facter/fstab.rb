# Contents of and current mount status of entries in /etc/fstab. This is completely
# different to the `mountpoint` fact which:
#   * doesn't include current status
#   * mangles UUIDs into devices
#   * includes all devices marked `ghost` in the `mount` provider
Facter.add(:fstab) do
  confine :kernel => "Linux"
  setcode do
    fstab = {}

    # we want a list of mounted filesystems from /proc/mounts - example
    # /dev/mapper/centos-home /home xfs rw,seclabel,relatime,attr2,inode64,noquota 0 0
    mounted_filesystems = File.readlines("/proc/mounts").map { |line|
      line.split(/\s+/)[1]
    }
    File.readlines("/etc/fstab").reject { |line|
      # skip lines with comments or consisting entirely of whitespace
      line =~ /^#/ || line =~ /^\s*$/
    }.each { |line|
      # fstab is formatted like this:
      # /dev/mapper/centos-root /                       xfs     defaults        0 0
      line_split = line.split(/\s+/)
      fstab[line_split[1]] = {}
      fstab[line_split[1]]["ensure"] = mounted_filesystems.include?(line_split[1]) ? 'mounted' : 'absent'
      fstab[line_split[1]]["device"] = line_split[0] || nil
      fstab[line_split[1]]["fstab"] = line_split[2] || nil
      fstab[line_split[1]]["options"] = line_split[3] || nil
      fstab[line_split[1]]["dump"] = line_split[4] || nil
      fstab[line_split[1]]["pass"] = line_split[5] || nil
    }

    fstab
  end
end
