# PastureStack Kubernetes Data Helper Image

`PastureStack/kubernetes-data-helper-image` is a minimal, one-shot container image for the legacy Kubernetes data-volume helper contract.

The container runs `/bin/true` as numeric user and group `65532:65532`, requires no network access, and exits successfully. It does not declare a volume itself; the historical catalog contract mounts `/data` and supplies the start-once behavior.

PastureStack is an independent community effort to preserve, audit, and modernize the Rancher 1.6 ecosystem. It is not affiliated with or endorsed by Rancher Labs or SUSE.

**Origin:** This is an independent Ubuntu 26.04 compatibility implementation. No public upstream repository could be verified, so it is intentionally not represented as a GitHub fork.

## Release image

The maintained release uses a pure numeric semantic version:

```text
ghcr.io/pasturestack/kubernetes-data-helper-image:v0.1.2
```

Release evidence records the immutable digest separately so a long digest never
appears in the user interface. Earlier non-numeric releases remain immutable
historical evidence and must not be copied into new release names.

## Build

Build the reviewed source tree:

```sh
docker build --pull \
  --build-arg IMAGE_VERSION=v0.1.2 \
  --build-arg SOURCE_REVISION="$(git rev-parse HEAD)" \
  --tag local/pasturestack/kubernetes-data-helper-image:v0.1.2 \
  .
```

The runtime base is pinned to the reviewed Ubuntu 26.04 `linux/amd64` manifest. Release evidence records the resulting image digest, SBOM, vulnerability scan, license inventory, and runtime tests.

## Smoke test

Run the image with the constraints supplied by the historical catalog and verify that it exits with status zero:

```sh
docker run --rm \
  --network none \
  --volume pasturestack-kubernetes-data-helper-poc:/data \
  local/pasturestack/kubernetes-data-helper-image:v0.1.2
test "$?" -eq 0
```

The named volume in this example is only test data. Remove it after the test:

```sh
docker volume rm pasturestack-kubernetes-data-helper-poc
```

See [COMPATIBILITY.md](COMPATIBILITY.md) for the preserved runtime contract and [ORIGIN.md](ORIGIN.md) for source provenance.

## Licensing

The repository work is provided under Apache License 2.0. The unchanged project license is copied into the image at `/usr/share/licenses/pasturestack-kubernetes-data-helper-image/LICENSE`.

The Ubuntu base image and its packages retain their own licenses and notices. The release process produces a CycloneDX SBOM and retains the Ubuntu package copyright files already present in the pinned base image. Generated release evidence is not committed to this source repository.
