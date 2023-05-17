#!/bin/bash

set -e

echo "escaped: $1"

bundle_image=$(systemd-escape -u "$1")
echo "unescaped: ${bundle_image}"

bundle_config=$(mktemp -p .)

podman run -t --rm -v /tmp/:/workspace ghcr.io/oras-project/oras::v1.0.0 pull \
    --plain-http \
    ${bundle_image} \
    --config ${bundle_config}

number_of_steps=$(jq '.steps | length' ${bundle_config})

for (( n=0; n<${number_of_steps}; n++ ))
do
    config=$(jq --argjson index ${n} '.steps[$index].config' ${bundle_config} -r)
    node=$(jq --argjson index ${n} '.steps[$index].node' ${bundle_config} -r)
    op=$(jq --argjson index ${n} '.steps[$index].op' ${bundle_config} -r)

    hirtectl start ${node} "apply-config@${op}-${config}.service"
done

rm ${bundle_config}
