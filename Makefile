.PHONY: setup configs config-engine config-radio config-vsomeip bundle-create bundle-replace bundle-delete

REGISTRY = localhost:5000
REPO = hirte
CONFIG_ARTIFACT_TYPE = application/vnd.containers.hirte.config.v1+json
BUNDLE_ARTIFACT_TYPE = application/vnd.containers.hirte.bundle.v1+json
TARGET_DIR = target

export

setup:
		podman run -d -p 5000:5000 ghcr.io/oras-project/registry:v1.0.0-rc.4

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
