#!/bin/bash

setupHosts () {
    echo "192.168.56.50 dc.example.redhat.com" > /etc/hosts
    echo "192.168.56.51 kafka1.example.redhat.com" >> /etc/hosts
    echo "192.168.56.52 kafka2.example.redhat.com" >> /etc/hosts
    echo "192.168.56.53 kafka3.example.redhat.com" >> /etc/hosts
}

setupPackages () {
    echo "Setup packages and configurations"

    sudo yum install -y krb5-server krb5-libs krb5-workstation pam_krb5 dnsmasq

    sudo cp /vagrant/server/krb5.conf /etc/krb5.conf
    sudo cp /vagrant/server/kdc.conf /var/kerberos/krb5kdc/kdc.conf
    sudo cp /vagrant/server/dnsmasq.conf /etc/dnsmasq.conf

    sudo systemctl start dnsmasq.service
}

createKerberosAdminUser () {
    user=$1
    pwd=$2
    
    if [ ! -f "/etc/krb5kdc/kadm5.keytab" ]; then
        echo "Create kerberos admin user [user=${user}, password=${pwd}, filename=kadm5.keytab]"

        #Initialize the Kerberos KDC database
        sudo kdb5_util create -s -P 123456

        sudo mkdir -p /etc/krb5kdc
        
        # Create an administrator user and keytab for administration of the Kerberos KDC
        sudo kadmin.local -q "ktadd -k /etc/krb5kdc/kadm5.keytab ${user}/${pwd}"

        # Start the Kerberos ticket server
        sudo systemctl start krb5kdc.service
        sudo systemctl start kadmin.service
    fi
}

createKerberosUser () {
    user=$1
    node=$2
    # Create users for kafka1 broker
    if [ ! -f "/tmp/${user}-${node}.keytab" ]; then
        echo "Create kerberos user [user=${user}, node=${node}, filename=${user}-${node}.keytab]"

        sudo kadmin.local \
            -q "addprinc -pw 123456 -kvno 0 ${user}/${node}.example.redhat.com" 
    
        sudo kadmin.local \
            -q "ktadd -k /tmp/${user}-${node}.keytab ${user}/${node}.example.redhat.com"

        sudo chown vagrant:vagrant /tmp/${user}-${node}.keytab
    fi
}

setupHosts
setupPackages
createKerberosAdminUser "kadmin" "admin"

createKerberosUser "kafka" "kafka1"
createKerberosUser "kafka" "kafka2"
createKerberosUser "kafka" "kafka3"

createKerberosUser "zookeeper" "kafka1"
createKerberosUser "zookeeper" "kafka2"
createKerberosUser "zookeeper" "kafka3"
