# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 
  if Vagrant.has_plugin? "vagrant-vbguest"
    config.vbguest.no_install  = true
    config.vbguest.auto_update = false
    config.vbguest.no_remote   = true
  end

  config.vm.define :servidorHA do |servidorHA|
    servidorHA.vm.box = "bento/ubuntu-18.04"
    servidorHA.vm.network :private_network, ip: "192.168.100.130"
    #servidorHA.vm.network :private_network, ip: "192.168.100.11"
    servidorHA.vm.hostname = "servidorHA"
    servidorHA.vm.provision :shell, path: "scriptHAPrueba.sh" 
  end 

  config.vm.define :machine1 do |machine1|
    machine1.vm.box = "bento/ubuntu-18.04"
    machine1.vm.network :private_network, ip: "192.168.100.110"
    machine1.vm.hostname = "machine1"
    machine1.vm.provision "file", source: "./index1.html", destination: "index1.html"
    machine1.vm.provision "file", source: "./index2b.html", destination: "index2b.html"
    machine1.vm.provision :shell, path: "scriptW1Prueba.sh"
  end

  config.vm.define :machine2 do |machine2|
    machine2.vm.box = "bento/ubuntu-18.04"
    machine2.vm.network :private_network, ip: "192.168.100.120"
    machine2.vm.hostname = "machine2"
    machine2.vm.provision "file", source: "./index2.html", destination: "index2.html"
    machine2.vm.provision "file", source: "./index1b.html", destination: "index1b.html"
   machine2.vm.provision :shell, path: "scriptW2Prueba.sh"
  end

  
end