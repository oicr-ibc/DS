Vagrant for R
=============

This small repository contains a setup that creates a small set of virtual machines
all running R code. To use it, you'll need [Vagrant](http://www.vagrantup.com/‎),
and possibly [Ansible](http://www.ansible.com).

Install "precise64" box:

```shell
$ vagrant box add precise64 http://files.vagrantup.com/precise64.box
```

Make sure to install ansible as well:

```shell
$ git clone https://github.com/ansible/ansible.git
```

Basic use:

```shell
$ git clone git@github.com:oicr-ibc/DS.git
$ cd DS
```

Create a file `vagrant_local.yml` containing something like this:

```yaml
---
provider:
  virtualbox:
    storage_root: '/var/local/...'
```

Then start your virtual machines:

```shell
$ vagrant up
```

By default this ccreates three machines, `worker-1`, `worker-2`, and `worker-3`, and
you can ssh to them as follows:

```shell
$ vagrant ssh worker-1
```

You can run a command on one machine:

```shell
$ vagrant ssh worker-1 -c "R --vanilla"
```

You can close down (halt) all the machines at once:

```shell
$ vagrant halt
```

Many of these commands also take a machine name, so `vagrant halt worker-2` works on that
specific machine. Use `vagrant help` for more.

You can delete all the machines at once:

```shell
$ vagrant destroy
```

All the machines are listed in `.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory`,
with port numbers for ssh, so you can manually use ssh/scp/... using a bit of underhand
workings (see below). The port number is automatically set as forwarded from localhost by Vagrant,
so each port will ssh to a different machine.

```shell
scp -P 2222 -i ~/.vagrant.d/insecure_private_key myfile.tar vagrant@localhost:/my/target
```
