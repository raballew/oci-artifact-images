#!/bin/bash

set -e

OP_CREATE="create"
OP_UPDATE="update"
OP_DELETE="delete"

echo "escaped: $1"

argument=$(systemd-escape -u "$1")
echo "unescaped: ${argument}"

op="$(cut -d '-' -f 1 <<< "$argument")"
config_image="$(cut -d '-' -f 2 <<< "$argument")"

files_dir=$(mktemp -d)

podman run -t --pull never --rm -v ${files_dir}:/workspace:z ghcr.io/oras-project/oras:latest manifest fetch \
    --plain-http \
    ${config_image} \
    --output manifest.json

podman run -t --pull never --rm -v ${files_dir}:/workspace:z ghcr.io/oras-project/oras:latest pull \
    --plain-http \
    ${config_image} \
    --output ./

number_of_layers=$(jq '.layers | length' ${files_dir}/manifest.json)

for (( n=0; n<${number_of_layers}; n++ ))
do
    file=$(jq --argjson index ${n} '.layers[$index].annotations."org.opencontainers.image.title"' ${files_dir}/manifest.json -r)
    path=$(jq --argjson index ${n} '.layers[$index].annotations.path' ${files_dir}/manifest.json -r)
    mode=$(jq --argjson index ${n} '.layers[$index].annotations.mode' ${files_dir}/manifest.json -r)

    if [ "$op" = "$OP_CREATE" ]; then
        if [ -f ${path} ]; then
            echo "error: file ${path} already exists and can not be created again."
            exit 1
        fi
        cp -f ${files_dir}/${file} ${path}
        chmod ${mode} ${path}
    elif [ "$op" = "$OP_UPDATE" ]; then
        if [ ! -f ${path} ]; then
            echo "error: file ${path} does not exist and can not be updated."
            exit 1
        fi
        rm ${path}
        cp -f ${files_dir}/${file} ${path}
        chmod ${mode} ${path}
    elif [ "$op" = "$OP_DELETE" ]; then
        if [ ! -f ${path} ]; then
            echo "error: file ${path} does not exist and can not be deleted."
            exit 1
        fi
        rm ${path}
    fi
done

rm -rf ${files_dir}
