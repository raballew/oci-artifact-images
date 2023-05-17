#!/bin/bash

set -e

bundle_image=$(systemd-escape -u "$1")
files_dir=$(mktemp -d)

podman run -t --rm -v ${files_dir}:/workspace:z ghcr.io/oras-project/oras:latest pull \
    --plain-http \
    ${bundle_image} \
    --config config.json

number_of_steps=$(jq '.steps | length' ${files_dir}/config.json)

for (( n=0; n<${number_of_steps}; n++ ))
do
    config=$(jq --argjson index ${n} '.steps[$index].config' ${files_dir}/config.json -r)
    node=$(jq --argjson index ${n} '.steps[$index].node' ${files_dir}/config.json -r)
    op=$(jq --argjson index ${n} '.steps[$index].op' ${files_dir}/config.json -r)

    service=$(systemd-escape "apply-config@${op}-${config}.service")
    hirtectl start ${node} ${service}
done

rm -rf ${files_dir}
