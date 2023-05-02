.PHONY: clean artifact

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
NAME := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

clean:
		rm -rf ./$(TARGET_DIR)
		mkdir ./$(TARGET_DIR)

artifact: clean
		oras push --oci-layout ./$(TARGET_DIR):latest --config configuration.json:$(CONFIG_ARTIFACT_TYPE) --annotation-file annotations.json $(NAME).service $(NAME).yml
		oras copy --from-oci-layout ./$(TARGET_DIR):latest $(REGISTRY)/$(REPO)/$(NAME)
