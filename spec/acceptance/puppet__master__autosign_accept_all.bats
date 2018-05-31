@test "autosign script removed" {
    ! ls /usr/local/bin/puppet_enterprise_autosign.sh
}

@test "autosign script disabled" {
    ! grep autosign /etc/puppetlabs/puppet.conf
}

@test "autosign.conf present" {
    ls /etc/puppetlabs/autosign.conf
}

@test "autosign.conf sign all"
    grep '*' /etc/puppetlabs/autosign.conf
}