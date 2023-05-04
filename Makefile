.PHONY: setup vm-images vm-instances configs config-engine config-radio config-vsomeip bundle-create bundle-replace bundle-delete

REGISTRY = localhost:5000
REPO = hirte
CONFIG_ARTIFACT_TYPE = application/vnd.containers.hirte.config.v1+json
BUNDLE_ARTIFACT_TYPE = application/vnd.containers.hirte.bundle.v1+json
TARGET_DIR = target

export

setup:
		podman run -d -p 5000:5000 ghcr.io/oras-project/registry:v1.0.0-rc.4

vm-images:
		sudo rm -rf ./$(TARGET_DIR)
		mkdir -p ./$(TARGET_DIR)
		git clone https://gitlab.com/CentOS/automotive/sample-images.git ./$(TARGET_DIR)
		rsync -a osbuild-manifests/ ./$(TARGET_DIR)/osbuild-manifests/
		make -C ./$(TARGET_DIR)/osbuild-manifests cs9-qemu-foo-ostree.x86_64.qcow2
		make -C ./$(TARGET_DIR)/osbuild-manifests cs9-qemu-bar-ostree.x86_64.qcow2
		make -C ./$(TARGET_DIR)/osbuild-manifests cs9-qemu-baz-ostree.x86_64.qcow2

vm-instances:


configs: config-engine config-radio config-vsomeip

config-engine:
		make -C configs/engine artifact

config-radio:
		make -C configs/radio artifact

config-vsomeip:
		make -C configs/vsomeip artifact

bundle-create: configs
		make -C bundle/ artifact OP="create"

bundle-replace: configs
		make -C bundle/ artifact OP="replace"

bundle-delete: configs
		make -C bundle/ artifact OP="delete"

all: setup configs bundles
