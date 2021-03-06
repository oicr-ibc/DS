# -*- mode: ruby -*-
# vi: set ft=ruby :


### First of all, let's use two YAML files, vagrant.yml and local.yml, to configure
### what we do. The vagrant.yml is required to exist. The local.yml is not, but
### overrides settings in vagrant.yml. This allows us to move stuff outside the
### core Vagrantfile. This same technique can be used to inject keys into Vagrant
### without using environment variables. We can also .gitignore local.yml, so that
### can remain secret.

require 'yaml'

### Shamelessly stolen from http://apidock.com/rails/v3.2.13/Hash/deep_merge%21
### Required to merge configuration data deeply.
def deep_merge!(hash, other_hash)
  other_hash.each_pair do |k,v|
    tv = hash[k]
    hash[k] = tv.is_a?(Hash) && v.is_a?(Hash) ? deep_merge!(tv, v) : v
  end
  hash
end

$VAGRANT_CONFIG = YAML.load_file('vagrant.yml')
if File.file?('vagrant_local.yml')
  user_settings = YAML.load_file('vagrant_local.yml')
else
  user_settings = {}
end
$VAGRANT_CONFIG = deep_merge!($VAGRANT_CONFIG, user_settings)

# require 'json'
# puts JSON.dump($VAGRANT_CONFIG)

# Now do the bulk of the configuration for Vagrant. This is a Ruby-driven multi-machine
# setup.

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  worker_vm_count = $VAGRANT_CONFIG['component_counts']['workers']

  @ansible_groups = {
    "worker" => (1..worker_vm_count).collect{ |i| "worker-#{i}" },
    "all_groups:children" => ["worker"]
  }

  # Calculate a set of static addresses. We might not even use these, but VirtualBox
  # is a bit funky about DHCP, so it's far easiest to use our own addresses and write
  # them in. For everything else, let's hope to goodness that we have a working DHCP.
  @ansible_ip_addresses = {}
  @address_low = 4

  def get_next_address()
    address = "192.168.50.#{@address_low}"
    @address_low = @address_low + 1
    return address
  end

  (1..worker_vm_count).each do |i|
    @ansible_ip_addresses["worker-#{i}"] = get_next_address()
  end

  # Core routine to provide basic configuration of a virtual machine. This is
  # refactoring convenience, to avoid duplicating stuff everywhere.
  def configure_virtual_machine(machine_name, machine_role, machine)
    machine.vm.box = "precise64"

    machine.vm.provider :virtualbox do |vb, override|

      memory_size = $VAGRANT_CONFIG['provider']['virtualbox']['components'][machine_role]['memory_size']

      vb.gui = false
      vb.customize ["modifyvm", :id, "--memory", memory_size]

      # For VirtualBox, and only for VirtualBox, override private networking to use our specified address
      override.vm.network "private_network", :virtualbox__intnet => true, :ip => @ansible_ip_addresses[machine_name]
    end

    machine.vm.provider :aws do |aws, override|
      override.vm.box = "dummy"

      aws.access_key_id = $VAGRANT_CONFIG['provider']['aws']['access_key_id']
      aws.secret_access_key = $VAGRANT_CONFIG['provider']['aws']['secret_access_key']
      aws.keypair_name = $VAGRANT_CONFIG['provider']['aws']['keypair_name']
      aws.ami = $VAGRANT_CONFIG['provider']['aws']['ami']
      aws.region = $VAGRANT_CONFIG['provider']['aws']['region']

      # These settings might need to be configured differently for each system
      aws.instance_type = $VAGRANT_CONFIG['provider']['aws']['components'][machine_role]['instance_type']
      tagged_name = $VAGRANT_CONFIG['provider']['aws']['name_prefix'] + machine_name
      aws.tags = { 'Name' => tagged_name }

      override.vm.network "private_network", :type => "dhcp"
      override.ssh.username = $VAGRANT_CONFIG['provider']['aws']['username']
      override.ssh.private_key_path = $VAGRANT_CONFIG['provider']['aws']['private_key_path']
    end
  end

  def add_storage(machine_name, machine_role, machine)
    machine.vm.provider :virtualbox do |vb|

      volume_size = $VAGRANT_CONFIG['provider']['virtualbox']['components'][machine_role]['volume_size']
      storage_root = $VAGRANT_CONFIG['provider']['virtualbox']['storage_root']
      file_to_disk = File.join(storage_root, "data-#{machine_name}.vdi")
      vb.customize ['createhd', '--filename', file_to_disk, '--size', volume_size * 1024]
      vb.customize ['storageattach', :id,
                    '--storagectl', 'SATA Controller',
                    '--port', 1,
                    '--device', 0,
                    '--type', 'hdd',
                    '--medium', file_to_disk]
    end

    machine.vm.provider :aws do |aws|
      volume_size = $VAGRANT_CONFIG['provider']['aws']['components'][machine_role]['volume_size']
      aws.block_device_mapping = [{
        'DeviceName' => '/dev/sdf1',
        'VirtualName' => 'ephemeral0',
        'Ebs.VolumeSize' => volume_size
      }]
    end

  end

  # We use a dummy playbook because (a) we want the ansible provisioner
  # to build an inventory but (b) we want to save the actual provisioning
  # until later so ansible can wire together systems effectively. See the
  # issue at: https://github.com/mitchellh/vagrant/issues/1784
  # There is no realworkaround on this yet.

  def configure_ansible(machine_name, machine_role, machine)
    machine.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision.yml"
      ansible.groups = @ansible_groups
      ansible.extra_vars = { :original_hostname => machine_name }
      ansible.limit = machine_name
    end
  end

  (1..worker_vm_count).each do |i|
    vm_name = "worker-#{i}"

    config.vm.define vm_name do |pipeline|
      configure_virtual_machine(vm_name, "worker", pipeline)
      configure_ansible(vm_name, "worker", pipeline)
      add_storage(vm_name, "worker", pipeline)
    end
  end

end
