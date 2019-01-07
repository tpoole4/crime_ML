# -*- mode: ruby -*-
# vi: set ft=ruby :
$install_ansible = <<-SCRIPT
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update
sudo apt-get install -y ansible
SCRIPT

$install_conda_env = <<-SCRIPT
cd /vagrant && make env
bash -lc "conda clean -y -a"
sudo bash -lc "conda clean -y --packages"
SCRIPT

unless Vagrant.has_plugin?("vagrant-vbguest")
  system("vagrant plugin install vagrant-vbguest")
  puts "Dependencies installed, please try the 'vagrant up' command again."
  exit
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "forwarded_port", guest: 8888, host: 8888, auto_correct: true
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = 2048
    vb.cpus = 1
  end
  config.vm.provision :shell do |shell|
    shell.name = "Install dependencies with apt package manager"
    shell.inline = $install_ansible
    shell.privileged = true
  end
  config.vm.provision :ansible_local do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.galaxy_role_file = "requirements.yml"
    ansible.galaxy_roles_path = "/home/vagrant/.ansible/roles"
  end
  config.vm.provision :shell do |shell|
    shell.name = "Create conda virtual environment"
    shell.inline = $install_conda_env
    shell.privileged = false
  end
end
