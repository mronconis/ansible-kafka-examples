#!/bin/bash

KEYTABS_LOCAL_DIR=files/kerberos/keytabs

copyKerberosUserKeytab () {
  user=$1
  node=$2

  if [ ! -d "$KEYTABS_LOCAL_DIR/${node}" ]; then
    mkdir -p $KEYTABS_LOCAL_DIR/$node
  fi

  echo "Copy to local dir '$KEYTABS_LOCAL_DIR' kerberos user keytab [user=${user}, node=${node}, filename=${user}-${node}.keytab]"

  vagrant --inventory=kerberos scp dc:/tmp/${user}-${node}.keytab files/kerberos/keytabs/${node}/${user}.keytab
}

copyKerberosUserKeytab "kafka" "kafka1"
copyKerberosUserKeytab "kafka" "kafka2"
copyKerberosUserKeytab "kafka" "kafka3"

copyKerberosUserKeytab "zookeeper" "kafka1"
copyKerberosUserKeytab "zookeeper" "kafka2"
copyKerberosUserKeytab "zookeeper" "kafka3"