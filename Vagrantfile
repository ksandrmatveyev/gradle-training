$collectd = <<SCRIPT
sudo yum install epel-release -y &&\
sudo yum install collectd -y &&\
sudo systemctl enable collectd &&\
sudo systemctl start collectd
SCRIPT

$configure_collectd = <<SCRIPT
yes | sudo cp -i /vagrant/collectd.conf /etc/collectd.conf &&\
sudo systemctl restart collectd
SCRIPT

$influxdb = <<SCRIPT
sudo yum install influxdb -y &&\
sudo systemctl enable influxdb &&\
sudo systemctl start influxdb
SCRIPT

$configure_influxdb = <<SCRIPT
yes | sudo cp -i /vagrant/influxdb.conf /etc/influxdb/influxdb.conf &&\
curl -G http://localhost:8086/query --data-urlencode "q=CREATE DATABASE collectd" &&\
sudo mkdir /usr/local/share/collectd &&\
sudo cp /vagrant/types.db /usr/local/share/collectd/types.db &&\
sudo systemctl restart influxdb
SCRIPT

$grafana = <<SCRIPT
sudo yum install https://grafanarel.s3.amazonaws.com/builds/grafana-4.1.2-1486989747.x86_64.rpm -y &&\
sudo /bin/systemctl daemon-reload &&\
sudo /bin/systemctl enable grafana-server.service &&\
sudo /bin/systemctl start grafana-server.service
SCRIPT


Vagrant.configure("2") do |config|
	config.vm.box = "bertvv/centos72"
	config.vm.provision "restart_network", run: "always", type: "shell", inline: "sudo systemctl restart network"
	config.vm.provision "disable_firewall", type: "shell", inline: "sudo systemctl stop firewalld && sudo systemctl disable firewalld"

	config.vm.define "node1" do |node1|
		node1.vm.hostname="node1"
		node1.vm.network "forwarded_port", guest: 22, host: 2022, id: "ssh"
		node1.vm.network "private_network", ip: "172.20.20.42"
		node1.vm.provision "run_install_collectd", type: "shell", inline: $collectd
		node1.vm.provision "configuring_manually_collectd", type: "shell", inline: "echo 'configure collectd: Uncommenting network plugin and setup settings to influxdb server, restart collectd'"
		node1.vm.provision "configuring_collectd", type: "shell", inline: $configure_collectd
	end

	config.vm.define "node2" do |node2|
		node2.vm.hostname="node2"
		node2.vm.network "forwarded_port", guest: 22, host: 2023, id: "ssh"
		node2.vm.network "private_network", ip: "172.20.20.43"
		node2.vm.provision "run_install_collectd", type: "shell", inline: $collectd
		node2.vm.provision "configuring_manually_collectd", type: "shell", inline: "echo 'configure collectd: Uncommenting network plugin and setup settings to influxdb server, restart collectd'"
		node2.vm.provision "configuring_collectd", type: "shell", inline: $configure_collectd
	end

	config.vm.define "monitoring" do |monitoring|
		monitoring.vm.hostname="monitoring"
		monitoring.vm.network "forwarded_port", guest: 22, host: 2021, id: "ssh"
		monitoring.vm.network "private_network", ip: "172.20.20.41"
    monitoring.vm.provision "put_to_repo1", type: "shell", path: "install_influxdb.sh"
    monitoring.vm.provision "run_install_influxdb", type: "shell", inline: $influxdb
		monitoring.vm.provision "configuring_manually_influxdb", type: "shell", inline: "echo 'configure influxdb: Uncommenting collectd settings, create database, restart service'"
		monitoring.vm.provision "configuring_influxdb", type: "shell", inline: $configure_influxdb
		monitoring.vm.provision "run_install_grafana", type: "shell", inline: $grafana
	end

end
