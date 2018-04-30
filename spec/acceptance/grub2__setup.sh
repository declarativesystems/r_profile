yum install -y grub2

# pretend to be physical
mkdir -p /etc/puppetlabs/facter/facts.d
echo "virtual=physical" > /etc/puppetlabs/facter/facts.d/virtual.txt

# fake grub2-probe since we're in a container and real one will error
cat <<EOF > /usr/sbin/grub2-probe
#!/bin/sh
echo FAKE
EOF
