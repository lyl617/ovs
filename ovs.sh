#!/bin/bash
cd /home/sdn/ovs/openvswitch-2.9.0


kill `cd /usr/local/var/run/openvswitch && cat ovsdb-server.pid ovs-vswitchd.pid`



rmmod openvswitch
./boot.sh
./configure --prefix=/usr --with-linux=/lib/modules/`uname -r`/build

make

make install 

make modules_install

# modinfo ./datapath/linux/openvswitch.ko | grep depend
modprobe gre
modprobe nf_conntrack
modprobe ip_tunnel
modprobe nf_defrag_ipv6
modprobe libcrc32c
modprobe nf_defrag_ipv4
insmod datapath/linux/openvswitch.ko

#insmod datapath/linux/openvswitch.ko

modprobe openvswitch

#ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach

#ovs-vsctl --no-wait init
#ovs-vswitchd --pidfile --detach

#yxw

mkdir -p /usr/local/etc/openvswitch
ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema

ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock \
                     --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
                     --private-key=db:Open_vSwitch,SSL,private_key \
                     --certificate=db:Open_vSwitch,SSL,certificate \
                     --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert \
                     --pidfile --detach

ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach
