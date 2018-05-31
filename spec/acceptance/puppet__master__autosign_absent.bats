@test "autosign script removed" {
    ! ls /usr/local/bin/puppet_enterprise_autosign.sh
}

@test "autosign script disabled" {
    ! grep autosign /etc/puppetlabs/puppet.conf
}

@test "autosign.conf removed" {
    ! ls /etc/puppetlabs/autosign.conf
}