.PHONY: setup teardown vm-images create-vm-instances delete-vm-instances configs config-engine config-radio config-vsomeip bundle-create bundle-update bundle-delete

REGISTRY = 172.16.100.1:5000
REPO = hirte
CONFIG_ARTIFACT_TYPE = application/vnd.containers.hirte.config.v1+json
BUNDLE_ARTIFACT_TYPE = application/vnd.containers.hirte.bundle.v1+json
TARGET_DIR = target

export

setup:	teardown
		podman run -d -p 5000:5000 ghcr.io/oras-project/registry:v1.0.0-rc.4
		sudo ip link add name br0 type bridge
		sudo ip address add 172.16.100.1/12 dev br0
		sudo ip link set up dev br0

teardown:
		- sudo ip link set down dev br0
		- sudo ip link del br0
		- podman stop --all
		- podman rm --all

vm-images:
		sudo rm -rf ./$(TARGET_DIR)
		mkdir -p ./$(TARGET_DIR)
		git clone https://gitlab.com/CentOS/automotive/sample-images.git ./$(TARGET_DIR)
		rsync -a osbuild-manifests/ ./$(TARGET_DIR)/osbuild-manifests/
		make -C ./$(TARGET_DIR)/osbuild-manifests cs9-qemu-foo-ostree.x86_64.qcow2
		make -C ./$(TARGET_DIR)/osbuild-manifests cs9-qemu-bar-ostree.x86_64.qcow2
		make -C ./$(TARGET_DIR)/osbuild-manifests cs9-qemu-baz-ostree.x86_64.qcow2

create-vm-instances:
		sudo ip tuntap add tap0 mode tap
		sudo ip tuntap add tap1 mode tap
		sudo ip tuntap add tap2 mode tap
		sudo ip link set tap0 master br0
		sudo ip link set tap1 master br0
		sudo ip link set tap2 master br0
		sudo ip link set up dev tap0
		sudo ip link set up dev tap1
		sudo ip link set up dev tap2
		sudo systemctl stop systemd-resolved
		- sudo pkill -9 dnsmasq
		sudo systemctl restart dnsmasq
		sudo qemu-system-x86_64 -name foo,process=qemu-vm-foo -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=/usr/share/OVMF/OVMF_VARS.fd,if=pflash,format=raw,unit=1,snapshot=on,readonly=off -smp 2 -enable-kvm -m 2G -machine q35 -cpu host -device virtio-net-pci,netdev=n0,mac=FE:16:bc:41:2d:20 -netdev tap,id=n0,ifname=tap0,script=no,downscript=no -drive file=./target/osbuild-manifests/cs9-qemu-foo-ostree.x86_64.qcow2,index=0,media=disk,format=qcow2,if=virtio,snapshot=off -daemonize
		sudo qemu-system-x86_64 -name bar,process=qemu-vm-bar -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=/usr/share/OVMF/OVMF_VARS.fd,if=pflash,format=raw,unit=1,snapshot=on,readonly=off -smp 2 -enable-kvm -m 2G -machine q35 -cpu host -device virtio-net-pci,netdev=n0,mac=FE:16:bc:41:2d:30 -netdev tap,id=n0,ifname=tap1,script=no,downscript=no -drive file=./target/osbuild-manifests/cs9-qemu-bar-ostree.x86_64.qcow2,index=0,media=disk,format=qcow2,if=virtio,snapshot=off -daemonize
		sudo qemu-system-x86_64 -name baz,process=qemu-vm-baz -drive file=/usr/share/OVMF/OVMF_CODE.fd,if=pflash,format=raw,unit=0,readonly=on -drive file=/usr/share/OVMF/OVMF_VARS.fd,if=pflash,format=raw,unit=1,snapshot=on,readonly=off -smp 2 -enable-kvm -m 2G -machine q35 -cpu host -device virtio-net-pci,netdev=n0,mac=FE:16:bc:41:2d:40 -netdev tap,id=n0,ifname=tap2,script=no,downscript=no -drive file=./target/osbuild-manifests/cs9-qemu-baz-ostree.x86_64.qcow2,index=0,media=disk,format=qcow2,if=virtio,snapshot=off -daemonize

delete-vm-instances:
		- sudo pkill -f process=qemu-vm-foo
		- sudo pkill -f process=qemu-vm-bar
		- sudo pkill -f process=qemu-vm-baz
		sudo ip link set tap0 nomaster
		sudo ip link set tap1 nomaster
		sudo ip link set tap2 nomaster
		sudo ip tuntap del tap0 mode tap
		sudo ip tuntap del tap1 mode tap
		sudo ip tuntap del tap2 mode tap

configs: config-engine config-radio config-vsomeip

config-engine:
		make -C configs/engine artifact

config-radio:
		make -C configs/radio artifact

config-vsomeip:
		make -C configs/vsomeip artifact

bundle-create: configs
		make -C bundle/ artifact OP="create"

bundle-update: configs
		make -C bundle/ artifact OP="update"

bundle-delete: configs
		make -C bundle/ artifact OP="delete"

all: setup configs bundles
