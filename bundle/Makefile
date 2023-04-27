.PHONY: clean config artifact

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
NAME := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

DIGEST_ENGINE = $(shell oras manifest fetch --oci-layout ../configs/engine/target:latest --descriptor | jq .digest)
DIGEST_RADIO = $(shell oras manifest fetch --oci-layout ../configs/radio/target:latest --descriptor | jq .digest)
DIGEST_VSOMEIP = $(shell oras manifest fetch --oci-layout ../configs/vsomeip/target:latest --descriptor | jq .digest)
OP = "create"

clean:
		rm -rf ./$(TARGET_DIR)
		mkdir ./$(TARGET_DIR)

config: JSON_FOO = $(shell jq -n --arg node "foo" --arg op "$(OP)" --arg config "$(REGISTRY)/$(REPO)/engine@$(DIGEST_ENGINE)" '$$ARGS.named' -c)
config: JSON_BAR = $(shell jq -n --arg node "bar" --arg op "$(OP)" --arg config "$(REGISTRY)/$(REPO)/radio@$(DIGEST_RADIO)" '$$ARGS.named' -c)
config: JSON_BAZ = $(shell jq -n --arg node "baz" --arg op "$(OP)" --arg config "$(REGISTRY)/$(REPO)/vsomeip@$(DIGEST_VSOMEIP)" '$$ARGS.named' -c)
config:
		jq -n -c -S --argjson steps '[$(JSON_FOO),$(JSON_BAR),$(JSON_BAZ)]' '$$ARGS.named' > config.json

artifact: clean config
		oras push --oci-layout ./$(TARGET_DIR):latest --config config.json:$(CONFIG_ARTIFACT_TYPE) --annotation-file annotations.json
		oras copy --from-oci-layout ./$(TARGET_DIR):latest $(REGISTRY)/$(REPO)/$(NAME)