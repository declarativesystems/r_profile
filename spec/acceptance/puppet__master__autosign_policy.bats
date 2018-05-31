@test "autosign script present" {
    ls /usr/local/bin/puppet_enterprise_autosign.sh
}

@test "autosign script enabled" {
    grep autosign /etc/puppetlabs/puppet.conf
}

@test "autosign.conf removed" {
    ! ls /etc/puppetlabs/autosign.conf
}

@test "secret in autosign script" {
    grep topsecret /usr/local/bin/puppet_enterprise_autosign.sh
}