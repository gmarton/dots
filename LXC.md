# LXD/LXC Notes (Arch)

## Official Guides
[Official LXD Documentation](https://documentation.ubuntu.com/lxd/en/latest/howto/)

## Install LXD (ipv6 disabled)

```bash
sudo pacman -S lxd

sudo mkdir /home/lxd
sudo pacman -S lxd
sudo systemctl start lxd.socket
sudo lxd init
```

When prompted during lxd init, use the following options to disable IPv6, and skip storage setup so you can add custom location later:

```
Would you like to use LXD clustering? (yes/no) [default=no]: 
Do you want to configure a new storage pool? (yes/no) [default=yes]: no
Would you like to connect to a MAAS server? (yes/no) [default=no]: 
Would you like to create a new local network bridge? (yes/no) [default=yes]: 
What should the new bridge be called? [default=lxdbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
Would you like the LXD server to be available over the network? (yes/no) [default=no]: 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
Would you like a YAML "lxd init" preseed to be printed? (yes/no) [default=no]:
```

Alternatively, you can use preseeded configuration:

```bash
    cat <<EOF | sudo lxd init --preseed
config: {}
networks:
- config:
    ipv4.address: auto
    ipv6.address: none
  description: ""
  name: lxdbr0
  type: ""
  project: default
storage_pools: []
profiles:
- config: {}
  description: ""
  devices:
    eth0:
      name: eth0
      network: lxdbr0
      type: nic
  name: default
projects: []
cluster: null
EOF
```
### Custom storage pool
```bash
sudo lxc storage create default dir source=/home/lxd
sudo lxc profile device add default root disk path=/ pool=default
sudo lxc storage list
```

## Example
### Create 22.04 Ubuntu image 

```bash
sudo lxc launch ubuntu:22.04 ubuntu
sudo lxc exec ubuntu -- /bin/bash
```
