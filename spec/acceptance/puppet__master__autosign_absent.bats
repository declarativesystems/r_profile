@test "autosign script removed" {
    ! ls /usr/local/bin/puppet_enterprise_autosign.sh
}

@test "autosigning disabled" {
    grep "autosign = false" /etc/puppetlabs/puppet/puppet.conf
}
