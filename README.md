# ansible-kafka-examples
Some examples of use of the [Ansible Kafka collection](https://github.com/saiello/kafka).

# Pre-requisite
Setup local environment

## Setup python virtual env
````
virtualenv .venv
source .venv/bin/activate
pip install -r requirements.txt
````

## Setup ansible-galaxy
````
ansible-galaxy install -r requirements.yml
````

# Examples
The local environment will have to be started through vagrant:
```
vagrant --inventory=<inventory_name> <vagrant command>
```

Notice: the empty option -- (two minus symbols) is used to end custom option processing:
```
vagrant --inventory=<inventory_name> -- <vagrant command> <vagrant options>
```

## Kafka/ZK plain
Start VMs
```
vagrant --inventory=plain -- up --provision
```

Stop VMs
```
vagrant --inventory=plain -- destroy --force
```

## Kafka/ZK mTLS
Generate certs
```
make -C files/tls/ca
make -C files/tls/ca install
```

Start VMs
```
vagrant --inventory=tls -- up --provision
```

Stop VMs
```
vagrant --inventory=tls -- destroy --force
```

Delete certs
```
make -C files/tls/ca clean
```

## Kafka/ZK SASL SCRAM
TBD.

## Kafka/ZK SASL Kerberos
Start VMs
```
vagrant --inventory=kerberos -- up --provision
```

Stop VMs
```
vagrant --inventory=kerberos -- destroy --force
```

## Kafka/ZK SASL OAuth

TBD.
