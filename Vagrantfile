require 'getoptlong'

# define options
opts = GetoptLong.new(
  [ '--inventory', GetoptLong::OPTIONAL_ARGUMENT ]
)

# defaults
inventory='plain'

# set args as options
opts.each do |opt, arg|
  case opt
    when '--inventory'
      inventory=arg
  end
end

# network
IP_NW="192.168.56."
IP_START_BROKER=50
BROKER_REPLICAS=3

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.synced_folder "files/#{inventory}", "/vagrant"

  if inventory == 'kerberos'
    # Kerberos (https://access.redhat.com/articles/5203171)
    config.vm.define "dc" do |dc|
      dc.vm.hostname = "dc.example.redhat.com"
      dc.vm.network "private_network", ip: "192.168.56.#{IP_START_BROKER}"
      dc.vm.network "forwarded_port", id: "ssh", guest: 22, host: 2200, auto_correct: false
      # Configure kerberos server and generate keytabs
      dc.vm.provision "shell", path: "files/kerberos/server/scripts/setup-kdc.sh"
    end

    # Copy generated keytabs to local repository
    config.trigger.after :up do |trigger|
      trigger.name = "Copy kerberos user keytabs to local dir"
      trigger.info = "Kerberos DC is up!"
      trigger.only_on = "dc"
      trigger.run = {path: "./files/kerberos/server/scripts/copy-keytabs.sh"}
    end

    # Fix CentOS baseurl repo
    machine.vm.provision "shell", inline: <<-SHELL
      sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=https://mirror.nsc.liu.se/centos-store|g" /etc/yum.repos.d/CentOS-*
      sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS-*
    SHELL
  end

  # Kafka/Zk
  (1..BROKER_REPLICAS).each do |machine_id|
    config.vm.define "kafka#{machine_id}", primary: true do |machine|
      machine.vm.hostname = "kafka#{machine_id}.example.redhat.com"
      machine.vm.network "private_network", ip: "#{IP_NW}#{IP_START_BROKER+machine_id}"
      machine.vm.network "forwarded_port", id: "ssh", guest: 22, host: "220#{machine_id}", auto_correct: false

      # Fix CentOS baseurl repo
      machine.vm.provision "shell", inline: <<-SHELL
        sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=https://mirror.nsc.liu.se/centos-store|g" /etc/yum.repos.d/CentOS-*
        sed -i s/^mirrorlist=http/#mirrorlist=http/g /etc/yum.repos.d/CentOS-*
      SHELL
      
      if inventory == 'kerberos'
        machine.vm.provision "shell", inline: <<-SHELL
          ###### Kerberos ######
          # Install kerberos client
          yum install -y krb5-workstation
          # Configure kerberos client
          cp /vagrant/client/krb5.conf /etc/krb5.conf
          # Empty /etc/hosts file
          echo -n > /etc/hosts
          # Empty /etc/resolv.conf file
          echo -n > /etc/resolv.conf
          # Add entries to resolv.conf file
          echo "domain example.redhat.com" > /etc/resolv.conf
          echo "nameserver 192.168.56.50" >> /etc/resolv.conf
          echo "nameserver 8.8.8.8" >> /etc/resolv.conf
          ###### Kerberos ###### 
        SHELL
      end

      if machine_id == BROKER_REPLICAS
        machine.vm.provision :ansible do |ansible|
          ansible.limit = "all"
          ansible.playbook = "setup.yml"
          ansible.inventory_path = "inventories/#{inventory}"
        end
      end

    end
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2 
  end

end
