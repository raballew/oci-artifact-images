#!/bin/bash

echo $1

bundle_config=$(mktemp -p .)

podman run -t --rm -v /tmp/:/workspace ghcr.io/oras-project/oras:latest pull \
    $1 \
    --config ${bundle_config}

number_of_steps=$(jq '.steps | length' ${bundle_config})

for (( n=0; c < ${number_of_steps}; n++ ))
do
   config=$(jq ".steps[${n}].config" ${bundle_config} -r)
   node=$(jq ".steps[${n}].node" ${bundle_config} -r)
   op=$(jq ".steps[${n}].op" ${bundle_config} -r)

   hirtectl start ${node} apply-config@${op}-${config}.service
done

rm ${bundle_config}

# oras pull localhost:5000/hirte/bundle@sha256:d8a0aabef1fc8d8501c586be0994be00f0c6b9b6b931e5eb9e4a9dca1498ad7e --config
