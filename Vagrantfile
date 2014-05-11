# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "hashicorp/precise64"
    config.vm.network :forwarded_port, host: 4000, guest: 4000
    config.vm.provision :shell, :path => "setup/bootstrap.sh"
end 
