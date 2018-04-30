# BATS test file to run before executing 'examples/init.pp' with puppet.
#
# For more info on BATS see https://github.com/sstephenson/bats

# Tests are really easy! just the exit status of running a command...
@test "selinux in testcase" {
  grep 'selinux=' /etc/grub.conf
}

@test "audit=0 present" {
  grep 'audit=0' /etc/grub.conf
}
