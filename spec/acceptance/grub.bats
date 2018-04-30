# BATS test file to run after executing 'examples/init.pp' with puppet.
#
# For more info on BATS see https://github.com/sstephenson/bats

# Tests are really easy! just the exit status of running a command...
@test "selinux gone" {
  ! grep 'selinux=' /etc/grub.conf
}

@test "audit=0 gone" {
  ! grep 'audit=0' /etc/grub.conf
}

@test "audit=1 added as default" {
  grep "^audit=1" /etc/grub.conf
}

@test "kernel lines all have audit=1" {
  ! grep '^[[:space:]]*kernel' /etc/grub.conf | grep -v audit=1
}
