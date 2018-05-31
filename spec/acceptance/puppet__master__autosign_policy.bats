@test "autosign script present" {
    ls /usr/local/bin/puppet_enterprise_autosign.sh
}

@test "autosign script enabled" {
    grep "autosign = /usr/local/bin/puppet_enterprise_autosign.sh" /etc/puppetlabs/puppet/puppet.conf
}

@test "secret in autosign script" {
    grep topsecret /usr/local/bin/puppet_enterprise_autosign.sh
}