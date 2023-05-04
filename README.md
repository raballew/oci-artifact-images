# SBOM OCI Artifact Images

## Manifest Config

According to [OCI Image Manifest
Specification](https://github.com/opencontainers/image-spec/blob/master/manifest.md#image-manifest-property-descriptions),
the property `config` is required by an image manifest. For content other than
OCI container images the `config.mediaType` value must be set to a value
[specific to the artifact
type](https://github.com/opencontainers/image-spec/blob/main/manifest.md#guidelines-for-artifact-usage)
or the [scratch
value](https://github.com/opencontainers/image-spec/blob/main/manifest.md#example-of-a-scratch-config-or-layer-descriptor).
`config.mediaType` must comply with [RFC
6838](https://tools.ietf.org/html/rfc6838), including the [naming requirements
in its section 4.2](https://datatracker.ietf.org/doc/html/rfc6838#section-4.2),
and may be registered with
[IANA](https://www.iana.org/assignments/media-types/media-types.xhtml)

The a default JSON format for the property `config` used to describe the image
is specified as part of the [OCI Image
Configuration](https://github.com/opencontainers/image-spec/blob/main/config.md)
document. It is worth noting that this format is often only useful when actually
running an OCI container image which is not the case here. Hence as custom
format could be used to better address the needs of this specific use case. This
leads to unexpected behaviors as various tools do not adhere to this standard.
For example, pushed images cannot be recognized or pulled by some versions of
`docker` as expected.

To push a pullable config the `oras` CLI can be used.

```bash
$ cat configuration.json
{
    "foo": "bar"
}

$ cat annotations.json
{
    "$config": {
        "org.opencontainers.image.title": "config.json"
    }
}

$ oras push --config configuration.json --annotation-file annotations.json localhost:5000/hello:latest hi.txt
Uploading a948904f2f0f hi.txt
Uploading 57f840b6073c config.json
Pushed localhost:5000/hello:latest
Digest: sha256:12e3de7e4a65ffc46a6158ac2df07ecc6fd1af8b0109b4c42a90067f7e907f43

$ oras pull -a localhost:5000/hello:latest
Downloaded a948904f2f0f hi.txt
Downloaded 57f840b6073c config.json
Pulled localhost:5000/hello:latest
Digest: sha256:12e3de7e4a65ffc46a6158ac2df07ecc6fd1af8b0109b4c42a90067f7e907f43
```

## Manifest Annotations

[Annotations](https://github.com/opencontainers/image-spec/blob/master/annotations.md),
which are supported by [OCI Image
Manifest](https://github.com/opencontainers/image-spec/blob/master/manifest.md#image-manifest)
and [OCI Content
Descriptors](https://github.com/opencontainers/image-spec/blob/master/descriptor.md)
can be used to make annotations to the manifest, the config, and individual
files using `oras` CLI. The details are described
[here](https://oras.land/cli/4_manifest_annotations/).

## Usage

This demo requires access to `ghcr.io` to setup a local artifact registry.

```bash
podman login ghcr.io
make setup
```

Now build two AutoSD flavours. One has the `hirte-agent` installed, whereas
the other has both `hirte-agent` and the `state-manager` installed.

```bash
make vm-images
```

Run one instance of the `state-manager` and two additional VMs.

```bash
make vm-instances
```

Then create, replace and delete the bundle:

```bash
make bundle-create
make bundle-replace
make bundle-delete
```
