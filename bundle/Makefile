.PHONY: clean config artifact

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
NAME := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

DIGEST_ENGINE := $(shell oras manifest fetch --oci-layout ../configs/engine/target:latest --descriptor | jq .digest)
DIGEST_RADIO := $(shell oras manifest fetch --oci-layout ../configs/radio/target:latest --descriptor | jq .digest)
DIGEST_VSOMEIP := $(shell oras manifest fetch --oci-layout ../configs/vsomeip/target:latest --descriptor | jq .digest)
OP = "create"

clean:
		rm -rf ./$(TARGET_DIR)
		mkdir ./$(TARGET_DIR)

config: JSON_FOO = $(shell jq -n --arg node "foo" --arg op "$(OP)" --arg config "$(REGISTRY)/$(REPO)/engine@$(DIGEST_ENGINE)" '$$ARGS.named' -c)
config: JSON_BAR = $(shell jq -n --arg node "bar" --arg op "$(OP)" --arg config "$(REGISTRY)/$(REPO)/radio@$(DIGEST_RADIO)" '$$ARGS.named' -c)
config: JSON_BAZ = $(shell jq -n --arg node "baz" --arg op "$(OP)" --arg config "$(REGISTRY)/$(REPO)/vsomeip@$(DIGEST_VSOMEIP)" '$$ARGS.named' -c)
config:
		jq -n -c -S --argjson steps '[$(JSON_FOO),$(JSON_BAR),$(JSON_BAZ)]' '$$ARGS.named' > configuration.json

artifact: clean config
		oras push --oci-layout ./$(TARGET_DIR):latest --config configuration.json:$(BUNDLE_ARTIFACT_TYPE) --annotation-file annotations.json
		oras copy --to-plain-http --from-oci-layout ./$(TARGET_DIR):latest $(REGISTRY)/$(REPO)/$(NAME)
#		- sshpass -p 'password' ssh root@172.16.100.20 -o "UserKnownHostsFile=/dev/null" -o PubkeyAuthentication=no -o PreferredAuthentications=password -o StrictHostKeyChecking=no -C
