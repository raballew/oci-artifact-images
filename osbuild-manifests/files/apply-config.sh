#!/bin/bash

set -e

OP_CREATE="create"
OP_UPDATE="update"
OP_DELETE="delete"

echo "escaped: $1"

argument=$(systemd-escape -u "$1")
echo "unescaped: ${argument}"

op="$(cut -d '-' -f 1 <<< "$argument")"
config_image="$(cut -d ';' -f 2- <<< "$argument")"

manifest=$(mktemp -p .)
files_dir=$(mktemp -p . -d)

podman run -t --rm -v /tmp/:/workspace ghcr.io/oras-project/oras:latest manifest fetch \
    --plain-http \
    ${config_image} > ${manifest}

podman run -t --rm -v /tmp/:/workspace ghcr.io/oras-project/oras:latest pull \
    --plain-http \
    ${config_image} \
    --output ${files_dir}

number_of_layers=$(jq '.layers | length' ${manifest})

for (( n=0; n<${number_of_layers}; n++ ))
do
    file=$(jq --argjson index ${n} '.layers[$index].annotations."org.opencontainers.image.title"' ${bundle_config} -r)
    path=$(jq --argjson index ${n} '.layers[$index].annotations.path' ${bundle_config} -r)
    op=$(jq --argjson index ${n} '.layers[$index].op' ${bundle_config} -r)

    if [ "$op" = "$OP_CREATE" ]; then
        cp -f ${files_dir}/${file} ${path}
    else if [ "$op" = "$OP_UPDATE" ]; then
        rm ${path}
        cp -f ${files_dir}/${file} ${path}
    else if [ "$op" = "$OP_DELETE" ]; then
        rm ${path}
    fi
done

rm ${manifest}
rm -rf ${files_dir}
