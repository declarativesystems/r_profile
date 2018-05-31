@test "autosign script removed" {
    ! ls /usr/local/bin/puppet_enterprise_autosign.sh
}

@test "autosign disabled" {
    grep "autosign = true" /etc/puppetlabs/puppet/puppet.conf
}
