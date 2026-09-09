# Compatibility Contract

This image preserves a narrow data-helper contract. It is not a Kubernetes service and does not contain control-plane logic.

## Preserved behavior

| Contract | Proof-of-concept behavior |
| --- | --- |
| Process | The image entrypoint is `/bin/true`. |
| Exit status | A normal run exits immediately with status zero. |
| Privileges | The process runs as numeric user and group `65532:65532`. |
| Network | The process requires no network access and can run with `--network none`. |
| Data path | The image does not declare a volume. The catalog mounts `/data`. |
| Lifecycle | The catalog, not the image, supplies the historical start-once label. |
| Configuration | The image accepts no required environment variables, ports, or credentials. |

The historical Kubernetes catalog used `busybox` for this role. Later private maintenance builds preserved the same role before the PastureStack migration. Private staging image names are intentionally omitted; they are recorded only in the local migration knowledge base.

## Isolated validation

Run this test on a Docker-capable validation host from a clean copy of the repository:

```sh
set -eu

image='local/pasturestack/kubernetes-data-helper-image:v0.1.2'
volume='pasturestack-kubernetes-data-helper-poc'

cleanup() {
  docker volume rm "$volume" >/dev/null 2>&1 || true
  docker image rm "$image" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker build --pull --no-cache --tag "$image" .
docker run --rm --network none --volume "$volume:/data" "$image"

test "$(docker image inspect --format '{{.Config.User}}' "$image")" = '65532:65532'
test "$(docker image inspect --format '{{json .Config.Entrypoint}}' "$image")" = '["/bin/true"]'
docker run --rm --entrypoint /bin/sh "$image" -c \
  'test -r /usr/share/licenses/pasturestack-kubernetes-data-helper-image/LICENSE'
```

This repository-level test does not authorize changing a catalog template or live environment. Catalog integration must be handled separately and must verify the `/data` volume and start-once lifecycle on the supported legacy host matrix.

## Catalog release gate

- Verify the pinned Ubuntu base manifest and the exact resulting release digest.
- Generate and review an SBOM, vulnerability scan, and Ubuntu package license inventory.
- Confirm that the image retains the Ubuntu-provided copyright files and the repository license.
- Verify the `/data` volume and start-once lifecycle in a real catalog deployment.
