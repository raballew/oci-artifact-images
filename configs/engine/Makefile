.PHONY: config

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
NAME := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

config:
		oras push --config config.json:$(CONFIG_ARTIFACT_TYPE) --annotation-file annotations.json $(REGISTRY)/$(REPO)/$(NAME) $(NAME).service $(NAME).yml
