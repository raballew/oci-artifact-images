.PHONY: setup configs config-engine config-radio config-vsomeip bundles bundle-install bundle-update all

REGISTRY = localhost:5000
REPO = hirte
CONFIG_ARTIFACT_TYPE = application/vnd.containers.hirte.config.v1+json
BUNDLE_ARTIFACT_TYPE = application/vnd.containers.hirte.bundle.v1+json

export

setup:
		podman run -d -p 5000:5000 ghcr.io/oras-project/registry:v1.0.0-rc.4

configs: config-engine config-radio config-vsomeip

config-engine:
		make -C configs/engine config

config-radio:
		make -C configs/radio config

config-vsomeip:
		make -C configs/vsomeip config

bundles: bundle-install bundle-update

bundle-install:

bundle-update:

all: setup configs bundles
